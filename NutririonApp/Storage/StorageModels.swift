import Foundation
import RealmSwift

class MealStorageViewModel: Object {

    @Persisted var name: String
    @Persisted var date: Date
    @Persisted var items: List<NutritionalItemStorageViewModel>

    override init() {}

    convenience init(from model: MealViewModel) {
        self.init()

        name = model.name
        date = model.date

        model.items.forEach { item in
            items.append(NutritionalItemStorageViewModel(from: item))
        }
    }

}

class NutritionalItemStorageViewModel: Object {

    @Persisted var name: String
    @Persisted var calories: Float
    @Persisted var fat_total_g: Float
    @Persisted var fat_saturated_g: Float
    @Persisted var protein_g: Float
    @Persisted var sodium_mg: Float
    @Persisted var potassium_mg: Float
    @Persisted var cholesterol_mg: Float
    @Persisted var carbohydrates_total_g: Float
    @Persisted var fiber_g: Float
    @Persisted var sugar_g: Float

    override init() {}

    convenience init(from model: NutritionalItemViewModel) {
        self.init()

        name = model.name
        calories = Float(model.calories)
        fat_total_g = Float(model.value(for: .fat_total_g))
        fat_saturated_g = Float(model.value(for: .fat_saturated_g))
        protein_g = Float(model.value(for: .protein_g))
        sodium_mg = Float(model.value(for: .sodium_mg))
        potassium_mg = Float(model.value(for: .potassium_mg))
        cholesterol_mg = Float(model.value(for: .cholesterol_mg))
        carbohydrates_total_g = Float(model.value(for: .carbohydrates_total_g))
        fiber_g = Float(model.value(for: .fiber_g))
        sugar_g = Float(model.value(for: .sugar_g))
    }

}
