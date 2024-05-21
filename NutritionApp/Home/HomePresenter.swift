import Combine
import Dependencies

struct DailyTarget {

    let calories: Float
    let gramsOfProtein: Float
    let gramsOfFat: Float
    let gramsOfCarbs: Float

}

struct DailyCalorieStats {

    let calories: Float
    let targetCalories: Float
    let burnedCalores: Float

    var calorieRatio: Float {
        ((calories / targetCalories) - 1) * 100
    }

    var ratioString: String {
        if calorieRatio < 100 {
            return "Deficit"
        } else if calorieRatio > 100 {
            return "Surplus"
        } else {
            return "At target"
        }
    }

}

class HomePresenter: ObservableObject {

    private let chartHeightOffset: Int = 400

    @Published var meals: [MealViewModel] = []
    @Published var dailyNutrition: [(Int, DailyNutrition)]?
    @Published var dailyTarget: DailyTarget?
    @Published var dailyStats: DailyCalorieStats?
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
        dailyNutrition = await storageUseCase.fetchCalories(from: 3).sorted { $0.0 > $1.0 }
        dailyTarget = await storageUseCase.fetchNecessaryCalories()
        calculateDailyStats()

        let maxCalorieValue = Int(dailyNutrition?.map { $0.1.calories }.max() ?? 0)
        chartHeight = max(maxCalorieValue, Int(dailyTarget?.calories ?? 0)) + chartHeightOffset
    }

    private func calculateDailyStats() {
        guard 
            let nutritionForToday,
            let dailyTarget
        else { return }

        dailyStats = DailyCalorieStats(
            calories: nutritionForToday.calories,
            targetCalories: dailyTarget.calories,
            burnedCalores: 0)
    }

}
