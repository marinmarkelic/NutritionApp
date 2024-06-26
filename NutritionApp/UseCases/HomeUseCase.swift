import Dependencies
import Combine
import Foundation

struct SelectedDayViewModel {

    let nutrition: DailyNutrition
    let meals: [MealViewModel]
    let dailyTarget: DailyTarget
    let burnedCalories: Int?

    func update(burnedCalories: Int) -> SelectedDayViewModel {
        .init(nutrition: nutrition, meals: meals, dailyTarget: dailyTarget, burnedCalories: burnedCalories)
    }

}


class HomeUseCase {

    var selectedDayPublisher: AnyPublisher<SelectedDayViewModel?, Never> {
        selectedDaySubject.eraseToAnyPublisher()
    }

    var dailyNuturitonsPublisher: AnyPublisher<[(Int, DailyNutrition)], Never> {
        dailyNuturitonsSubject.eraseToAnyPublisher()
    }

    var dailyMealsPublisher: AnyPublisher<[MealViewModel], Never> {
        dailyMealsSubject.eraseToAnyPublisher()
    }

    @Dependency(\.nutritionDataUseCase)
    private var nutritionDataUseCase: NutritionDataUseCase
    @Dependency(\.healthKitUseCase)
    private var healthKitUseCase: HealthKitUseCase

    private var selectedDaySubject: CurrentValueSubject<SelectedDayViewModel?, Never> = .init(nil)
    private var dailyNuturitonsSubject: CurrentValueSubject<[(Int, DailyNutrition)], Never> = .init([])
    private var dailyMealsSubject: CurrentValueSubject<[MealViewModel], Never> = .init([])
    private var disposables = Set<AnyCancellable>()

    init() {
        bindUseCase()
    }

    func fetchDailyNutritions() async {
        var dailyNutritions = await nutritionDataUseCase.fetchCalories(from: .daysAgo(30)).sorted { $0.0 > $1.0 }

        let isTodayEmpty = !dailyNutritions.map { $0.0 }.contains(0)
        let shouldInsertToday = isTodayEmpty && dailyNutritions.count > 0
        if shouldInsertToday {
            dailyNutritions.insert((0, DailyNutrition()), at: 0)
        }

        dailyNuturitonsSubject.send(dailyNutritions)
    }

    func fetchSelectedDay(day: FetchTimeline) async {
        guard let date = day.date else { return }

        await changeNutrition(for: date)
        await changeMeals(for: date)
        healthKitUseCase.reloadBurnedEnergy(for: date)
    }

    func delete(meal: MealViewModel) async {
        await nutritionDataUseCase.delete(meal: meal)
    }

    private func changeNutrition(for date: Date) async {
        let nutrition = await nutritionDataUseCase.fetchCalories(for: date) ?? DailyNutrition()
        let meals = await nutritionDataUseCase.fetchMeals(with: date).sorted { $0.date > $1.date }
        let dailyTarget = await nutritionDataUseCase.fetchNecessaryCalories() ?? .empty

        selectedDaySubject.send(SelectedDayViewModel(nutrition: nutrition, meals: meals, dailyTarget: dailyTarget, burnedCalories: nil))
    }

    private func changeMeals(for date: Date) async {
        let meals = await nutritionDataUseCase.fetchMeals(with: date)
        dailyMealsSubject.send(meals)
    }

    private func bindUseCase() {
        healthKitUseCase
            .burntCaloriesPublisher
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard
                    let self,
                    let value,
                    let subjectValue = selectedDaySubject.value
                else { return }

                selectedDaySubject.send(subjectValue.update(burnedCalories: Int(value)))
            }
            .store(in: &disposables)
    }

}

extension HomeUseCase: DependencyKey {

    static var liveValue: HomeUseCase {
        HomeUseCase()
    }

}

extension DependencyValues {

    var homeUseCase: HomeUseCase {
        get { self[HomeUseCase.self] }
        set { self[HomeUseCase.self] = newValue }
    }

}
