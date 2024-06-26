struct DailyTarget {

    let calories: Float
    let nutrients: NutrientValues

    static let empty = DailyTarget(calories: 0, nutrients: .empty)

}

struct DailyCalorieStats {

    let calories: Float
    let targetCalories: Float
    let burnedCalores: Float


}

struct SelectedDayViewModel {

    let nutrition: DailyNutrition
    let meals: [MealViewModel]
    let dailyTarget: DailyTarget
    let burnedCalories: Int?

    func update(burnedCalories: Int) -> SelectedDayViewModel {
        .init(nutrition: nutrition, meals: meals, dailyTarget: dailyTarget, burnedCalories: burnedCalories)
    }

}
