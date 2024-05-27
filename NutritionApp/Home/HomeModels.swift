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
            return "Deficit"
        } else if calorieRatio > 100 {
            return "Surplus"
        } else {
            return "At target"
        }
    }

}
