import Foundation
import Dependencies

actor StorageUseCase {

    @Dependency(\.storageService)
    private var service: StorageService

    func save(userMetric: Any?, for key: String) {
        service.save(value: userMetric, for: key)
    }

    func userMetric(for key: String) -> Any? {
        service.object(for: key)
    }

    func save(meal: MealViewModel) {
        service.save(meal: meal)
    }

    func fetchMeals(with date: Date) -> [MealViewModel] {
        service.fetchMeals(with: date)
    }

    func fetchMeals(from daysAgo: Int) -> [MealViewModel] {
        service.fetchMeals(from: daysAgo)
    }

    func fetchCalories(from daysAgo: Int) -> [(Int, Int)] {
        let meals = service.fetchMeals(from: daysAgo)

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
        service.print()
    }

    func deleteAll() {
        service.deleteAll()
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
