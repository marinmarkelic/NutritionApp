import Combine
import Dependencies

class HomePresenter: ObservableObject {

    private let chartHeightOffset: Int = 400

    @Published var meals: [MealViewModel] = []
    @Published var calories: [(Int, Int)]?
    @Published var dailyTarget: Float?
    @Published var chartHeight: Int = 0

    @Dependency(\.storageUseCase) var storageUseCase

    @MainActor
    func fetchMeals() async {
        meals = await storageUseCase.fetchMeals(from: 3)
    }

    @MainActor
    func fetchCalories() async {
        let fetchedArray = [(0, 500), (-1, 1567), (-2, 1467)]
        calories = fetchedArray
        dailyTarget = await storageUseCase.fetchNecessaryCalories()

        let maxCalorieValue = fetchedArray.map { $0.1 }.max() ?? 0
        chartHeight = max(maxCalorieValue, Int(dailyTarget ?? 0)) + chartHeightOffset
    }

}
