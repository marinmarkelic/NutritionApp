struct MealViewModel: Equatable, CustomStringConvertible {

    let name: String
    let items: [NutritionalItemViewModel]

    var calories: Float {
        var calories: Float = 0

        for item in items {
            calories += item.calories
        }

        return calories
    }

    var nutrients: [Nutrient : Float] {
        guard !items.isEmpty else { return [:] }

        guard items.count > 1 else {
            return items.first!.nutrients
        }

        var nutrients: [Nutrient : Float] = Dictionary(uniqueKeysWithValues: Nutrient.allCases.map { ($0, 0) })

        for item in items {
            for nutrient in Nutrient.allCases {
                guard
                    let itemValue = item.nutrients[nutrient],
                    let currentValue = nutrients[nutrient]
                else { continue }

                nutrients[nutrient] = itemValue + currentValue
            }
        }

        return nutrients
    }

    var description: String {

        return "\(calories)g of calories, \(nutrients[.protein_g] ?? 0)g of protein, \(nutrients[.fat_total_g] ?? 0)g of fat, \(nutrients[.carbohydrates_total_g] ?? 0)g of carbs"

    }

}

extension MealViewModel {

    init(from model: MealNetworkViewModel, with name: String) {
        self.name = name
        items = model.items.compactMap { NutritionalItemViewModel(from: $0) }
    }

}

struct NutritionalItemViewModel: Equatable {

    let name: String
    let calories: Float
    let serving_size_g: Float
    let nutrients: [Nutrient : Float]

}

extension NutritionalItemViewModel {

    init(from model: NutritionalItemNetworkViewModel) {
        name = model.name
        calories = model.calories
        serving_size_g = model.serving_size_g

        var nutrients = [Nutrient: Float]()
        for nutrient in Nutrient.allCases {
            switch nutrient {
            case .fat_total_g:
                nutrients[nutrient] = model.fat_total_g
            case .fatSaturated_g:
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

}

extension NutritionalItemViewModel: CustomStringConvertible {

    var description: String {

        return "\(calories)g of calories, \(nutrients[.protein_g] ?? 0)g of protein, \(nutrients[.fat_total_g] ?? 0)g of fat, \(nutrients[.carbohydrates_total_g] ?? 0)g of carbs"

    }

}

enum Nutrient: String, CaseIterable {

    case fat_total_g
    case fatSaturated_g
    case protein_g
    case sodium_mg
    case potassium_mg
    case cholesterol_mg
    case carbohydrates_total_g
    case fiber_g
    case sugar_g

}

