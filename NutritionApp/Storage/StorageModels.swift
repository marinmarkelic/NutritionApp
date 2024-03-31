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
    @Persisted var calories_baseline: Float
    @Persisted var serving_size_g: Float
    @Persisted var serving_size_baseline_g: Float
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
        calories_baseline = Float(model.calories_baseline)
        serving_size_g = Float(model.serving_size_g)
        serving_size_baseline_g = Float(model.serving_size_baseline_g)
        fat_total_g = Float(model.value(for: .fat_total_g, ignoringMultiplier: true))
        fat_saturated_g = Float(model.value(for: .fat_saturated_g, ignoringMultiplier: true))
        protein_g = Float(model.value(for: .protein_g, ignoringMultiplier: true))
        sodium_mg = Float(model.value(for: .sodium_mg, ignoringMultiplier: true))
        potassium_mg = Float(model.value(for: .potassium_mg, ignoringMultiplier: true))
        cholesterol_mg = Float(model.value(for: .cholesterol_mg, ignoringMultiplier: true))
        carbohydrates_total_g = Float(model.value(for: .carbohydrates_total_g, ignoringMultiplier: true))
        fiber_g = Float(model.value(for: .fiber_g, ignoringMultiplier: true))
        sugar_g = Float(model.value(for: .sugar_g, ignoringMultiplier: true))
    }

}
