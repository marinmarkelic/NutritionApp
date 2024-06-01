struct DailyTarget {

    let calories: Float
    let nutrients: NutrientValues

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
            return Strings.deficit.capitalized
        } else if calorieRatio > 100 {
            return Strings.surplus.capitalized
        } else {
            return Strings.atTarget.rawValue
        }
    }

}
