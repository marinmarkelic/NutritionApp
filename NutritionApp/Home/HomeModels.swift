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
