import Dependencies

actor RatingsUseCase {

    @Dependency(\.openAIClient)
    private var client: OpenAIClient

    @Dependency(\.storageService)
    private var storageService: StorageService

    func queryRatings(for amountOfDays: Int = 3) {
        let meals = fetchMeals(from: amountOfDays)

        let dates = Array(Set(meals.map { $0.date.onlyDate! }))
        var nutritions = [DailyNutrition]()
        for date in dates {
            var dailyNutrition = DailyNutrition()

            for meal in meals {
                if Calendar.current.isDate(meal.date, inSameDayAs: date) {
                    dailyNutrition = dailyNutrition.add(meal)
                }
            }

            nutritions.append(dailyNutrition)
        }

        print("--- \(nutritions)")
    }

    private func fetchMeals(from daysAgo: Int) -> [MealViewModel] {
        storageService.fetchMeals(from: daysAgo)
    }

}

import Foundation

struct DailyNutrition {

    let calories: CGFloat
    let protein: CGFloat
    let carbohydrates: CGFloat
    let fat: CGFloat
    let items: [String]

    init(
        calories: CGFloat = 0,
        protein: CGFloat = 0,
        carbohydrates: CGFloat = 0,
        fat: CGFloat = 0,
        items: [String] = []
    ) {
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.items = items
    }

    func add(_ model: MealViewModel) -> DailyNutrition {
        DailyNutrition(
            calories: (calories + model.calories).rounded(),
            protein: (protein + model.getNutrientValue(for: .protein_g)).rounded(),
            carbohydrates: (carbohydrates + model.getNutrientValue(for: .carbohydrates_total_g)).rounded(),
            fat: (fat + model.getNutrientValue(for: .fat_total_g)).rounded(),
            items: items + [model.name])
    }

}

extension RatingsUseCase: DependencyKey {

    static var liveValue: RatingsUseCase {
        RatingsUseCase()
    }

}

extension DependencyValues {

    var ratingsUseCase: RatingsUseCase {
        get { self[RatingsUseCase.self] }
        set { self[RatingsUseCase.self] = newValue }
    }

}
