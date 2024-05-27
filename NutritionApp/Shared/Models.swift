import Foundation
import SwiftUI

enum Nutrient: String, CaseIterable, Identifiable {

    case fat_total_g
    case fat_saturated_g
    case protein_g
    case sodium_mg
    case potassium_mg
    case cholesterol_mg
    case carbohydrates_total_g
    case fiber_g
    case sugar_g

    var id: String {
        self.rawValue
    }

    var title: String {
        switch self {
        case .fat_total_g:
            "Fat"
        case .fat_saturated_g:
            "Saturated Fat"
        case .protein_g:
            "Protein"
        case .sodium_mg:
            "Sodium"
        case .potassium_mg:
            "Potassium"
        case .cholesterol_mg:
            "Cholesterol"
        case .carbohydrates_total_g:
            "Carbohydrates"
        case .fiber_g:
            "Fiber"
        case .sugar_g:
            "Sugar"
        }
    }

    var color: Color {
        switch self {
        case .fat_total_g:
            return Color.fat
        case .fat_saturated_g:
            return Color.fatSaturated
        case .protein_g:
            return Color.protein
        case .sodium_mg:
            return Color.sodium
        case .potassium_mg:
            return Color.potassium
        case .cholesterol_mg:
            return Color.cholesterol
        case .carbohydrates_total_g:
            return Color.carbs
        case .fiber_g:
            return Color.fiber
        case .sugar_g:
            return Color.sugar
        }
    }

}

struct DailyNutrition {

    let calories: Float
    let nutrients: [Nutrient: Float]
    let items: [String]

    init(
        calories: Float = 0,
        nutrients: [Nutrient: Float] = [:],
        items: [String] = []
    ) {
        self.calories = calories
        self.nutrients = nutrients
        self.items = items
    }

    func add(_ model: MealViewModel) -> DailyNutrition {
        var nutrients = self.nutrients
        model.nutrients.keys.forEach { nutrient in
            let currentValue = nutrients[nutrient] ?? .zero
            let addingValue = model.nutrients[nutrient] ?? .zero

            nutrients[nutrient] = currentValue + addingValue
        }

        return DailyNutrition(
            calories: (calories + model.calories).rounded(),
            nutrients: nutrients,
            items: items + [model.name])
    }

}

extension DailyNutrition {

    init(from model: MealViewModel) {
        calories = model.calories.rounded()
        nutrients = model.nutrients
        items = [model.name]
    }

}
