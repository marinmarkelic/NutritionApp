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

    @Dependency(\.storageUseCase) private var storageUseCase

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
        dailyNutrition = await storageUseCase.fetchCalories(from: 3)
        dailyTarget = await storageUseCase.fetchNecessaryCalories()

        let maxCalorieValue = Int(dailyNutrition?.map { $0.1.calories }.max() ?? 0)
        chartHeight = max(maxCalorieValue, Int(dailyTarget?.calories ?? 0)) + chartHeightOffset
    }

}
