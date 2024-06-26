import Foundation
import Charts
import SwiftUI

typealias NutrientValues = [Nutrient: Float]

extension NutrientValues {

    // NutrientValues with all values of 0

    static let empty: NutrientValues = {
        var values: NutrientValues = [:]
        Nutrient.allCases.forEach { values[$0] = .zero }
        return values
    }()

    func sortedByValue(ascending: Bool = true) -> [(Nutrient, Float)] {
        if ascending {
            return self.sorted { $0.value * $0.key.unit.multiplier < $1.value * $1.key.unit.multiplier }
        } else {
            return self.sorted { $0.value * $0.key.unit.multiplier > $1.value * $1.key.unit.multiplier }
        }
    }

    func sortedByValue(andScaledTo calories: Float, ascending: Bool = true) -> [(Nutrient, Float)] {
        var totalAmount: Float = .zero
        self.forEach { (key, value) in
            totalAmount += value * key.unit.multiplier
        }

        var newArray: [(Nutrient, Float)]
        if ascending {
            newArray = self.sorted { $0.value * $0.key.unit.multiplier < $1.value * $1.key.unit.multiplier }
        } else {
            newArray = self.sorted { $0.value * $0.key.unit.multiplier > $1.value * $1.key.unit.multiplier }
        }

        return newArray.map { (key, value) in
            let newValue = calories * value / totalAmount
            return (key, newValue)
        }
    }

}

enum MeasuringUnit: String {

    case grams = "Grams"
    case milligrams = "Milligrams"

    var shortened: String {
        switch self {
        case .grams:
            "g"
        case .milligrams:
            "mg"
        }
    }

    var multiplier: Float {
        switch self {
        case .grams:
            1
        case .milligrams:
            0.001
        }
    }

}

enum Nutrient: String, CaseIterable, Identifiable, Plottable {

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

    var primitivePlottable: String {
        title
    }

    var title: String {
        switch self {
        case .fat_total_g:
            Strings.fat.rawValue
        case .fat_saturated_g:
            Strings.fatSaturated.rawValue
        case .protein_g:
            Strings.protein.rawValue
        case .sodium_mg:
            Strings.sodium.rawValue
        case .potassium_mg:
            Strings.potassium.rawValue
        case .cholesterol_mg:
            Strings.cholesterol.rawValue
        case .carbohydrates_total_g:
            Strings.carbohydrates.rawValue
        case .fiber_g:
            Strings.fiber.rawValue
        case .sugar_g:
            Strings.sugar.rawValue
        }
    }

    var unit: MeasuringUnit {
        switch self {
        case .fat_total_g, .fat_saturated_g, .protein_g, .carbohydrates_total_g, .fiber_g, .sugar_g:
            return .grams
        case .sodium_mg, .potassium_mg, .cholesterol_mg:
            return .milligrams
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

    init?(primitivePlottable: String) {
        switch primitivePlottable {
        case Strings.fat.rawValue:
            self = .fat_total_g
        case Strings.fatSaturated.rawValue:
            self = .fat_saturated_g
        case Strings.protein.rawValue:
            self = .protein_g
        case Strings.sodium.rawValue:
            self = .sodium_mg
        case Strings.potassium.rawValue:
            self = .potassium_mg
        case Strings.cholesterol.rawValue:
            self = .cholesterol_mg
        case Strings.carbohydrates.rawValue:
            self = .carbohydrates_total_g
        case Strings.fiber.rawValue:
            self = .fiber_g
        case Strings.sugar.rawValue:
            self = .sugar_g
        default:
            return nil
        }
    }


    func baselineValue(for value: Float) -> Float {
        value * unit.multiplier
    }

}

struct DailyNutrition {

    let calories: Float
    let nutrients: NutrientValues
    let items: [String]

    init(
        calories: Float = 0,
        nutrients: NutrientValues = .empty,
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
