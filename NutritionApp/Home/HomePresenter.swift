import Combine
import Dependencies
import Foundation

class HomePresenter: ObservableObject {

    enum HomeState {

        case loading
        case loaded
        case empty

    }

    private let chartHeightOffset: Int = 400

    @Published var isChartLegendVisible: Bool = false

    @Published var state: HomeState = .loading
    @Published var dailyNutritions: [(Int, DailyNutrition)] = []
    @Published var selectedDay: FetchTimeline = .today
    @Published var selectedDayNutrition: SelectedDayViewModel?
    @Published var selectedDayMeals: [MealViewModel] = []

    @Dependency(\.homeUseCase)
    private var homeUseCase: HomeUseCase

    private var disposables = Set<AnyCancellable>()

    init() {
        bindUseCase()
    }

    func updateDate(with date: Date) {
        Task {
            guard let day = FetchTimeline(date: date) else { return }

            selectedDay = day
            await homeUseCase.fetchSelectedDay(day: day)
        }
    }

    func delete(meal: MealViewModel) {
        Task {
            await homeUseCase.delete(meal: meal)
            await homeUseCase.fetchSelectedDay(day: selectedDay)
            await homeUseCase.fetchDailyNutritions()
        }
    }

    func toggleLegendVisibility() {
        isChartLegendVisible.toggle()
    }

    func onAppear() async {
        await homeUseCase.fetchSelectedDay(day: selectedDay)
        await homeUseCase.fetchDailyNutritions()
    }

    private func bindUseCase() {
        homeUseCase
            .dailyNuturitonsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] dailyNutritions in
                guard let self else { return }

                self.state = dailyNutritions.isEmpty ? .empty : .loaded
                self.dailyNutritions = dailyNutritions
            }
            .store(in: &disposables)

        homeUseCase
            .selectedDayPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedDay in
                guard let self, let selectedDay else { return }

                selectedDayNutrition = selectedDay
            }
            .store(in: &disposables)

        homeUseCase
            .dailyMealsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] meals in
                self?.selectedDayMeals = meals
            }
            .store(in: &disposables)
    }

}
