import Combine
import Dependencies
import Foundation

class HomePresenter: ObservableObject {

    private let chartHeightOffset: Int = 400

    @Published var meals: [MealViewModel] = []
    @Published var nutritionForToday: DailyNutrition?
    @Published var dailyNutrition: [(Int, DailyNutrition)]?
    @Published var dailyTarget: DailyTarget?
    @Published var burnedCalories: Int?
    @Published var chartHeight: Int = 0
    @Published var isChartLegendVisible: Bool = false

    @Dependency(\.storageUseCase) 
    private var storageUseCase: StorageUseCase
    @Dependency(\.healthKitUseCase)
    private var healthKitUseCase: HealthKitUseCase

    private var disposables = Set<AnyCancellable>()

    init() {
        bindUseCase()
    }

    @MainActor
    func fetchMeals() async {
        meals = await storageUseCase.fetchMeals(from: .daysAgo(3)).sorted  { first, second in
            first.date > second.date
        }
    }

    @MainActor
    func fetchCalories() async {
        dailyNutrition = await storageUseCase.fetchCalories(from: .daysAgo(3)).sorted { $0.0 > $1.0 }
        nutritionForToday = await storageUseCase.fetchCalories(from: .today).first?.1
        dailyTarget = await storageUseCase.fetchNecessaryCalories()

        let maxCalorieValue = Int(dailyNutrition?.map { $0.1.calories }.max() ?? 0)
        chartHeight = max(maxCalorieValue, Int(dailyTarget?.calories ?? 0)) + chartHeightOffset
    }

    func delete(meal: MealViewModel) {
        Task {
            await storageUseCase.delete(meal: meal)
            await fetchMeals()
            await fetchCalories()
        }
    }

    func toggleLegendVisibility() {
        isChartLegendVisible.toggle()
    }


    private func bindUseCase() {
        healthKitUseCase
            .burntCaloriesPublisher
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self, let value else { return }

                burnedCalories = Int(value)
            }
            .store(in: &disposables)
    }

}
