import Foundation
import SwiftUI

struct MealViewModel: Equatable, CustomStringConvertible, Identifiable {

    let name: String
    let date: Date
    let items: [NutritionalItemViewModel]

    var id: String {
        date.description
    }

    var calories: Float {
        var calories: Float = 0

        for item in items {
            calories += item.calories
        }

        return calories
    }

    var graphData: GraphViewModel {
        GraphViewModel(from: self)
    }

    func value(for nutrient: Nutrient) -> Float {
        guard !items.isEmpty else { return .zero }

        var value: Float = .zero
        for item in items {
            value += item.value(for: nutrient)
        }

        return value
    }

    var weight: Float {
        var value: Float = .zero
        for item in items {
            value += item.serving_size_g
        }
        return value
    }

    var nutrients: [Nutrient : Float] {
        guard !items.isEmpty else { return [:] }

        var nutrients: [Nutrient : Float] = Dictionary(uniqueKeysWithValues: Nutrient.allCases.map { ($0, 0) })

        for item in items {
            for nutrient in Nutrient.allCases {
                guard
                    let currentValue = nutrients[nutrient]
                else { continue }

                let itemValue = item.value(for: nutrient)
                nutrients[nutrient] = itemValue + currentValue
            }
        }

        return nutrients
    }

    var description: String {
"""
Name: \(name)
\(weight)g,
\(calories)g of calories,
\(nutrients[.protein_g] ?? 0)g of protein,
\(nutrients[.fat_total_g] ?? 0)g of fat,
\(nutrients[.carbohydrates_total_g] ?? 0)g of carbs
"""
    }

    func update(servingSize: Float, for item: NutritionalItemViewModel) -> MealViewModel {
        var items: [NutritionalItemViewModel] = []
        self.items.forEach { nutritionItem in
            if nutritionItem == item {
                items.append(nutritionItem.with(servingSize: servingSize))
            } else {
                items.append(nutritionItem)
            }
        }

        return MealViewModel(name: name, date: date, items: items)
    }

}

extension MealViewModel {

    init(from model: MealNetworkViewModel, with name: String) {
        self.name = name
        date = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        items = model.items.compactMap { NutritionalItemViewModel(from: $0) }
    }

    init(from model: MealStorageViewModel) {
        name = model.name
        date = model.date
        items = model.items.map { NutritionalItemViewModel(from: $0) }
    }

}

struct NutritionalItemViewModel: Equatable {

    let name: String
    let serving_size_g: Float
    let serving_size_baseline_g: Float
    let calories_baseline: Float
    private let nutrients: [Nutrient : Float]

    // Temp
    var totalG: Float {
        nutrients[.carbohydrates_total_g]! + nutrients[.fat_total_g]! + nutrients[.protein_g]!
    }

    var serving_size_multiplier: Float {
        serving_size_g / serving_size_baseline_g
    }

    var calories: Float {
        calories_baseline * serving_size_multiplier
    }

    static func colorFor(nutrient: Nutrient) -> Color {
        switch nutrient {
        case .fat_total_g:
            return .yellow
        case .protein_g:
               return .red
        case .carbohydrates_total_g:
               return .green
        default:
            return .clear
        }
    }

    func value(for nutrient: Nutrient, ignoringMultiplier: Bool = false) -> Float {
        let multiplier = ignoringMultiplier ? 1 : serving_size_multiplier
        return (nutrients[nutrient] ?? 0) * multiplier
    }

    func with(servingSize: Float) -> NutritionalItemViewModel {
        NutritionalItemViewModel(
            name: name,
            serving_size_g: servingSize,
            serving_size_baseline_g: serving_size_baseline_g,
            calories_baseline: calories_baseline,
            nutrients: nutrients)
    }

}

extension NutritionalItemViewModel {

    init(from model: NutritionalItemNetworkViewModel) {
        name = model.name
        calories_baseline = model.calories
        serving_size_g = model.serving_size_g
        serving_size_baseline_g = model.serving_size_g

        var nutrients = NutrientValues()
        for nutrient in Nutrient.allCases {
            switch nutrient {
            case .fat_total_g:
                nutrients[nutrient] = model.fat_total_g
            case .fat_saturated_g:
                nutrients[nutrient] = model.fat_saturated_g
            case .protein_g:
                nutrients[nutrient] = model.protein_g
            case .sodium_mg:
                nutrients[nutrient] = model.sodium_mg
            case .potassium_mg:
                nutrients[nutrient] = model.potassium_mg
            case .cholesterol_mg:
                nutrients[nutrient] = model.cholesterol_mg
            case .carbohydrates_total_g:
                nutrients[nutrient] = model.carbohydrates_total_g
            case .fiber_g:
                nutrients[nutrient] = model.fiber_g
            case .sugar_g:
                nutrients[nutrient] = model.sugar_g
            }
        }
        self.nutrients = nutrients
    }

    init(from model: NutritionalItemStorageViewModel) {
        name = model.name
        calories_baseline = model.calories_baseline
        serving_size_g = model.serving_size_g
        serving_size_baseline_g = model.serving_size_baseline_g

        var nutrients = NutrientValues()
        for nutrient in Nutrient.allCases {
            switch nutrient {
            case .fat_total_g:
                nutrients[nutrient] = model.fat_total_g
            case .fat_saturated_g:
                nutrients[nutrient] = model.fat_saturated_g
            case .protein_g:
                nutrients[nutrient] = model.protein_g
            case .sodium_mg:
                nutrients[nutrient] = model.sodium_mg
            case .potassium_mg:
                nutrients[nutrient] = model.potassium_mg
            case .cholesterol_mg:
                nutrients[nutrient] = model.cholesterol_mg
            case .carbohydrates_total_g:
                nutrients[nutrient] = model.carbohydrates_total_g
            case .fiber_g:
                nutrients[nutrient] = model.fiber_g
            case .sugar_g:
                nutrients[nutrient] = model.sugar_g
            }
        }
        self.nutrients = nutrients

//        print("--- from storage \(self.description)")
    }

}

extension NutritionalItemViewModel: CustomStringConvertible {

    var description: String {
"""
Name: \(name)
\(serving_size_g)g \(serving_size_baseline_g)g,
\(calories)g of calories,
\(nutrients[.protein_g] ?? 0)g of protein,
\(nutrients[.fat_total_g] ?? 0)g of fat,
\(nutrients[.carbohydrates_total_g] ?? 0)g of carbs
"""
    }

}

struct GraphViewModelData {

    // rename properties
    let color: Color
    let previousCompleton: CGFloat
    let completion: CGFloat

}

struct GraphViewModel {

    static let evaluatedNutrients = Nutrient.allCases

    let data: [GraphViewModelData]

    fileprivate init(from model: MealViewModel) {
        var progress: CGFloat = 0
        var sum: CGFloat = 0
        GraphViewModel.evaluatedNutrients.forEach { nutrient in
            sum += CGFloat(model.value(for: nutrient) * nutrient.unit.multiplier)
        }

        var data = [GraphViewModelData]()
        GraphViewModel.evaluatedNutrients.forEach { nutrient in
            data.append(
                GraphViewModelData(
                    color: nutrient.color,
                    previousCompleton: progress,
                    completion: CGFloat(model.value(for: nutrient) * nutrient.unit.multiplier) / sum))

            progress += CGFloat(model.value(for: nutrient) * nutrient.unit.multiplier) / sum
        }

        self.data = data
    }

}
