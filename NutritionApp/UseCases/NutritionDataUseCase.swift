import Foundation
import Dependencies

actor NutritionDataUseCase {

    @Dependency(\.storageService)
    private var storageService: StorageService
    @Dependency(\.energyExpenditureService)
    private var energyExpenditureService: EnergyExpenditureService

    func save(userData: UserData) {
        var keyedValues: [String : Any] = [:]
        keyedValues[UserDefaultsKey.sex.rawValue] = userData.sex?.rawValue
        keyedValues[UserDefaultsKey.age.rawValue] = userData.age
        keyedValues[UserDefaultsKey.height.rawValue] = userData.height
        keyedValues[UserDefaultsKey.weight.rawValue] = userData.weight
        keyedValues[UserDefaultsKey.activityType.rawValue] = userData.activityFrequency?.rawValue
        storageService.setValuesForKeys(keyedValues)
    }

    func fetchUserData() -> UserData {
        var sex: Sex? = nil
        if let sexString = storageService.object(for: UserDefaultsKey.sex.rawValue) as? String {
            sex = Sex(rawValue: sexString)
        }

        let age = storageService.object(for: UserDefaultsKey.age.rawValue) as? Int
        let height = storageService.object(for: UserDefaultsKey.height.rawValue) as? Int
        let weight = storageService.object(for: UserDefaultsKey.weight.rawValue) as? Int

        var activityFrequency: ActivityFrequency? = nil
        if let activityFrequencyString = storageService.object(for: UserDefaultsKey.activityType.rawValue) as? String {
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

    func save(conversation: ConversationHistoryEntry) {
        storageService.save(conversation: conversation)
    }

    func fetchCoversations() -> [ConversationHistoryEntry] {
        storageService.fetchConversations()
    }

    func fetchMeals(with date: Date) -> [MealViewModel] {
        storageService.fetchMeals(with: date)
    }

    func fetchMeals(from timeline: FetchTimeline) -> [MealViewModel] {
        storageService.fetchMeals(from: timeline)
    }

    func fetchNecessaryCalories() -> DailyTarget? {
        guard
            let sexString = userMetric(for: UserDefaultsKey.sex.rawValue) as? String,
            let sex = Sex(rawValue: sexString),
            let phisicalActivityString = userMetric(for: UserDefaultsKey.activityType.rawValue) as? String,
            let phisicalActivity = ActivityFrequency(rawValue: phisicalActivityString),
            let age = userMetric(for: UserDefaultsKey.age.rawValue) as? Int,
            let height = userMetric(for: UserDefaultsKey.height.rawValue) as? Int,
            let weight = userMetric(for: UserDefaultsKey.weight.rawValue) as? Float
        else { return nil }

        let calories = energyExpenditureService
            .totalDailyEnergyExpenditure(
                for: sex,
                age: age,
                height: height,
                weight: Int(weight),
                phisicalActivity: phisicalActivity)

        let protein = energyExpenditureService.gramsOfProtein(for: weight, and: age)
        let fat = energyExpenditureService.gramsOfFat(for: age, and: calories)
        let carbs = energyExpenditureService.gramsOfCarbs()
        let sodium = energyExpenditureService.milligramsOfSodium(for: age)
        let potassium = energyExpenditureService.milligramsOfPotassium(for: age, and: sex)
        let fiber = energyExpenditureService.gramsOfFiber(for: calories)
        let sugar = energyExpenditureService.gramsOfSugar(for: calories)

        var nutrients: NutrientValues = .empty
        nutrients[.protein_g] = protein
        nutrients[.fat_total_g] = fat
        nutrients[.carbohydrates_total_g] = carbs
        nutrients[.sodium_mg] = sodium
        nutrients[.potassium_mg] = potassium
        nutrients[.fiber_g] = fiber
        nutrients[.sugar_g] = sugar

        return DailyTarget(calories: calories, nutrients: nutrients)
     }

    func fetchCalories(for date: Date) -> DailyNutrition? {
        let meals = storageService.fetchMeals(with: date)
        var nutrition = DailyNutrition()
        for meal in meals {
            nutrition = nutrition.add(meal)
        }
        return nutrition
    }

    func fetchCalories(from timeline: FetchTimeline) -> [(Int, DailyNutrition)] {
        let meals = storageService.fetchMeals(from: timeline)

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

    private func userMetric(for key: String) -> Any? {
        storageService.object(for: key)
    }

}

extension NutritionDataUseCase: DependencyKey {

    static var liveValue: NutritionDataUseCase {
        NutritionDataUseCase()
    }

}

extension DependencyValues {

    var nutritionDataUseCase: NutritionDataUseCase {
        get { self[NutritionDataUseCase.self] }
        set { self[NutritionDataUseCase.self] = newValue }
    }

}
