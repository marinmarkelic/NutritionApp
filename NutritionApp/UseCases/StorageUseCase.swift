import Foundation
import Dependencies

actor StorageUseCase {

    @Dependency(\.storageService)
    private var storageService: StorageService
    @Dependency(\.energyExpenditureService)
    private var energyExpenditureService: EnergyExpenditureService

    func save(userMetric: Any?, for key: String) {
        storageService.save(value: userMetric, for: key)
    }

    func userMetric(for key: String) -> Any? {
        storageService.object(for: key)
    }

    func save(meal: MealViewModel) {
        storageService.save(meal: meal)
    }

    func fetchMeals(with date: Date) -> [MealViewModel] {
        storageService.fetchMeals(with: date)
    }

    func fetchMeals(from daysAgo: Int) -> [MealViewModel] {
        storageService.fetchMeals(from: daysAgo)
    }

    func fetchNecessaryCalories() -> Float? {
        guard
            let sexStr = userMetric(for: "sex") as? String,
            let sex = Sex(rawValue: sexStr),
            let phisicalActivityStr = userMetric(for: "activityType") as? String,
            let phisicalActivity = ActivityFrequency(rawValue: phisicalActivityStr),
            let age = userMetric(for: "age") as? Int,
            let height = userMetric(for: "height") as? Int,
            let weight = userMetric(for: "weight") as? Int
        else { return nil }

        return energyExpenditureService
            .totalDailyEnergyExpenditure(
                for: sex,
                age: age,
                height: height,
                weight: weight,
                phisicalActivity: phisicalActivity)
     }

    func fetchCalories(from daysAgo: Int) -> [(Int, Int)] {
        let meals = storageService.fetchMeals(from: daysAgo)

        /// (Days ago, Calories)
        var caloriesForDaysAgo: [Int: Int] = [:]
        meals.forEach { meal in
            let daysAgo = meal.date.distance(from: .now, only: .day)
            let calories = meal.calories

            guard let writtenCalories = caloriesForDaysAgo[daysAgo] else {
                caloriesForDaysAgo[daysAgo] = Int(calories)
                return
            }

            caloriesForDaysAgo[daysAgo] = Int(calories) + writtenCalories
        }

        var calorieArray: [(Int, Int)] = []
        caloriesForDaysAgo.keys.forEach { key in
            let key = Int(key)
            guard let calories = caloriesForDaysAgo[key] else { return }

            calorieArray.append((key, calories))
        }

        print(caloriesForDaysAgo)

        return calorieArray
    }

    func printAll() {
        storageService.print()
    }

    func deleteAll() {
        storageService.deleteAll()
    }

}

extension StorageUseCase: DependencyKey {

    static var liveValue: StorageUseCase {
        StorageUseCase()
    }

}

extension DependencyValues {

    var storageUseCase: StorageUseCase {
        get { self[StorageUseCase.self] }
        set { self[StorageUseCase.self] = newValue }
    }

}
