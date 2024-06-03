import Foundation
import Dependencies

actor StorageUseCase {

    @Dependency(\.storageService)
    private var storageService: StorageService
    @Dependency(\.energyExpenditureService)
    private var energyExpenditureService: EnergyExpenditureService

    func save(userData: UserData) {
        var keyedValues: [String : Any] = [:]
        keyedValues["sex"] = userData.sex?.rawValue
        keyedValues["age"] = userData.age
        keyedValues["height"] = userData.height
        keyedValues["weight"] = userData.weight
        keyedValues["activityType"] = userData.activityFrequency?.rawValue
        print(keyedValues)
        storageService.setValuesForKeys(keyedValues)
    }

    func fetchUserData() -> UserData {
        var sex: Sex? = nil
        if let sexString = storageService.object(for: "sex") as? String {
            sex = Sex(rawValue: sexString)
        }

        let age = storageService.object(for: "age") as? Int
        let height = storageService.object(for: "height") as? Int
        let weight = storageService.object(for: "weight") as? Int

        var activityFrequency: ActivityFrequency? = nil
        if let activityFrequencyString = storageService.object(for: "activityType") as? String {
            activityFrequency = ActivityFrequency(rawValue: activityFrequencyString)
        }

        return UserData(sex: sex, age: age, height: height, weight: weight, activityFrequency: activityFrequency)
    }

    func save(meal: MealViewModel) {
        storageService.save(meal: meal)
    }

    func delete(meal: MealViewModel) {
        storageService.delete(meal: meal)
    }

    func save(conversation: ConversationViewModel) {
        storageService.save(conversation: conversation)
    }

    func fetchCoversations() -> [ConversationViewModel] {
        storageService.fetchConversations()
    }

    func fetchMeals(with date: Date) -> [MealViewModel] {
        storageService.fetchMeals(with: date)
    }

    func fetchMeals(from daysAgo: Int) -> [MealViewModel] {
        storageService.fetchMeals(from: daysAgo)
    }

    func fetchNecessaryCalories() -> DailyTarget? {
        guard
            let sexString = userMetric(for: "sex") as? String,
            let sex = Sex(rawValue: sexString),
            let phisicalActivityString = userMetric(for: "activityType") as? String,
            let phisicalActivity = ActivityFrequency(rawValue: phisicalActivityString),
            let age = userMetric(for: "age") as? Int,
            let height = userMetric(for: "height") as? Int,
            let weight = userMetric(for: "weight") as? Float
        else { return nil }

        let calories = energyExpenditureService
            .totalDailyEnergyExpenditure(
                for: sex,
                age: age,
                height: height,
                weight: Int(weight),
                phisicalActivity: phisicalActivity)

        let protein = energyExpenditureService.gramsOfProtein(for: weight)
        let fat = energyExpenditureService.gramsOfFat(for: calories)
        let carbs = energyExpenditureService.gramsOfCarbs(for: calories, gramsOfProtein: protein, gramsOfFat: fat)
        let sodium = energyExpenditureService.milligramsOfSodium()
        let cholesterol = energyExpenditureService.milligramsOfCholesterol()
        let potassium = energyExpenditureService.milligramsOfPotassium(for: sex)
        let fiber = energyExpenditureService.gramsOfFiber(for: calories)
        let sugar = energyExpenditureService.gramsOfSugar(for: calories)

        var nutrients: NutrientValues = .empty
        nutrients[.protein_g] = protein
        nutrients[.fat_total_g] = fat
        nutrients[.carbohydrates_total_g] = carbs
        nutrients[.sodium_mg] = sodium
        nutrients[.cholesterol_mg] = cholesterol
        nutrients[.potassium_mg] = potassium
        nutrients[.fiber_g] = fiber
        nutrients[.sugar_g] = sugar

        return DailyTarget(calories: calories, nutrients: nutrients)
     }

    func fetchCalories(from daysAgo: Int) -> [(Int, DailyNutrition)] {
        let meals = storageService.fetchMeals(from: daysAgo)

        /// (Days ago, Calories)
        var caloriesForDaysAgo: [Int: DailyNutrition] = [:]
        meals.forEach { meal in
            let daysAgo = meal.date.distance(from: .now, only: .day)

            guard let writtenCalories = caloriesForDaysAgo[daysAgo] else {
                caloriesForDaysAgo[daysAgo] = DailyNutrition(from: meal)
                return
            }

            caloriesForDaysAgo[daysAgo] = writtenCalories.add(meal)
        }

        var calorieArray: [(Int, DailyNutrition)] = []
        caloriesForDaysAgo.keys.forEach { key in
            let key = Int(key)
            guard let calories = caloriesForDaysAgo[key] else { return }

            calorieArray.append((key, calories))
        }

        return calorieArray
    }

    func printAll() {
        storageService.print()
    }

    func deleteAll() {
        storageService.deleteAll()
    }

    private func userMetric(for key: String) -> Any? {
        storageService.object(for: key)
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
