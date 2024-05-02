import Combine
import Dependencies

struct DailyTarget {

    let calories: Float
    let gramsOfProtein: Float
    let gramsOfFat: Float
    let gramsOfCarbs: Float

}

class HomePresenter: ObservableObject {

    private let chartHeightOffset: Int = 400

    @Published var meals: [MealViewModel] = []
    @Published var dailyNutrition: [(Int, DailyNutrition)]?
    @Published var dailyTarget: DailyTarget?
    @Published var chartHeight: Int = 0

    @Dependency(\.storageUseCase) var storageUseCase

    var nutritionForToday: DailyNutrition? {
        guard let nutrition = dailyNutrition?.first(where: { $0.0 == 0 }) else { return nil }

        return nutrition.1
    }

    @MainActor
    func fetchMeals() async {
        meals = await storageUseCase.fetchMeals(from: 3)
    }

    @MainActor
    func fetchCalories() async {
        let fetchedArray = [
            (0, DailyNutrition(calories: 500, protein: 60, carbohydrates: 200, fat: 300, items: [])),
            (-1, DailyNutrition(calories: 1573, protein: 100, carbohydrates: 700, fat: 300, items: [])),
            (-2, DailyNutrition(calories: 1467, protein: 150, carbohydrates: 200, fat: 400, items: []))
        ]
        dailyNutrition = fetchedArray
        dailyTarget = await storageUseCase.fetchNecessaryCalories()

        let maxCalorieValue = Int(fetchedArray.map { $0.1.calories }.max() ?? 0)
        chartHeight = max(maxCalorieValue, Int(dailyTarget?.calories ?? 0)) + chartHeightOffset
    }

    @MainActor
    func fetchCalories() {
        Task { [weak self] in
            guard let self else { return }

//            calories = await storageUseCase.fetchCalories(from: 3)
            let fetchedArray = [(0, 500), (-1, 1567), (-2, 1467)]
            calories = fetchedArray
            chartHeight = (fetchedArray.map { $0.1 }.max() ?? 0) + chartHeightOffset
        }
    }

}
