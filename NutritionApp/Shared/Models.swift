import Foundation

struct DailyNutrition {

    let calories: Float
    let protein: Float
    let carbohydrates: Float
    let fat: Float
    let items: [String]

    init(
        calories: Float = 0,
        protein: Float = 0,
        carbohydrates: Float = 0,
        fat: Float = 0,
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
            protein: (protein + model.value(for: .protein_g)).rounded(),
            carbohydrates: (carbohydrates + model.value(for: .carbohydrates_total_g)).rounded(),
            fat: (fat + model.value(for: .fat_total_g)).rounded(),
            items: items + [model.name])
    }

}

extension DailyNutrition {

    init(from model: MealViewModel) {
        calories = model.calories.rounded()
        protein = model.value(for: .protein_g).rounded()
        carbohydrates = model.value(for: .carbohydrates_total_g).rounded()
        fat = model.value(for: .fat_total_g).rounded()
        items = [model.name]
    }

}
