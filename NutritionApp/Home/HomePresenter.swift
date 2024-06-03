import Combine
import Dependencies
import Foundation

class HomePresenter: ObservableObject {

    private let chartHeightOffset: Int = 400

    @Published var meals: [MealViewModel] = []
    @Published var dailyNutrition: [(Int, DailyNutrition)]?
    @Published var dailyTarget: DailyTarget?
    @Published var burnedCalories: Int?
    @Published var dailyStats: DailyCalorieStats?
    @Published var chartHeight: Int = 0

    @Dependency(\.storageUseCase) 
    private var storageUseCase: StorageUseCase
    @Dependency(\.healthKitUseCase)
    private var healthKitUseCase: HealthKitUseCase

    private var disposables = Set<AnyCancellable>()

    var nutritionForToday: DailyNutrition? {
        guard let nutrition = dailyNutrition?.first(where: { $0.0 == 0 }) else { return nil }

        return nutrition.1
    }

    init() {
        bindUseCase()
    }

    @MainActor
    func fetchMeals() async {
        meals = await storageUseCase.fetchMeals(from: 1)
    }

    @MainActor
    func fetchCalories() async {
        dailyNutrition = await storageUseCase.fetchCalories(from: 3).sorted { $0.0 > $1.0 }
        dailyTarget = await storageUseCase.fetchNecessaryCalories()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.calculateDailyStats()
        }

        let maxCalorieValue = Int(dailyNutrition?.map { $0.1.calories }.max() ?? 0)
        chartHeight = max(maxCalorieValue, Int(dailyTarget?.calories ?? 0)) + chartHeightOffset
    }

    func delete(meal: MealViewModel) {
        Task {
            await storageUseCase.delete(meal: meal)
            await fetchMeals()
        }
    }

    private func calculateDailyStats() {
        guard let dailyTarget else { return }

        dailyStats = DailyCalorieStats(
            calories: nutritionForToday?.calories ?? .zero,
            targetCalories: dailyTarget.calories,
            burnedCalores: 0)
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
