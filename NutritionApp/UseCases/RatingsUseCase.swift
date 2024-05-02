import Dependencies
import Foundation

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
