import Foundation
import RealmSwift

@objc(MealStorageViewModel)
class MealStorageViewModel: Object {

    @objc dynamic var name: String = ""
    @objc dynamic var date: Date = Date()
    dynamic var items = List<NutritionalItemStorageViewModel>()

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

@objc(NutritionalItemStorageViewModel)
class NutritionalItemStorageViewModel: Object {

    @objc dynamic var name: String = ""
    @objc dynamic var calories: Float = 0
    @objc dynamic var fat_total_g: Float = 0
    @objc dynamic var fat_saturated_g: Float = 0
    @objc dynamic var protein_g: Float = 0
    @objc dynamic var sodium_mg: Float = 0
    @objc dynamic var potassium_mg: Float = 0
    @objc dynamic var cholesterol_mg: Float = 0
    @objc dynamic var carbohydrates_total_g: Float = 0
    @objc dynamic var fiber_g: Float = 0
    @objc dynamic var sugar_g: Float = 0

    override init() {}

    convenience init(from model: NutritionalItemViewModel) {
        self.init()

        name = model.name
        calories = Float(model.calories)
        fat_total_g = Float(model.nutrients[.fat_total_g] ?? 0)
        fat_saturated_g = Float(model.nutrients[.fat_saturated_g] ?? 0)
        protein_g = Float(model.nutrients[.protein_g] ?? 0)
        sodium_mg = Float(model.nutrients[.sodium_mg] ?? 0)
        potassium_mg = Float(model.nutrients[.potassium_mg] ?? 0)
        cholesterol_mg = Float(model.nutrients[.cholesterol_mg] ?? 0)
        carbohydrates_total_g = Float(model.nutrients[.carbohydrates_total_g] ?? 0)
        fiber_g = Float(model.nutrients[.fiber_g] ?? 0)
        sugar_g = Float(model.nutrients[.sugar_g] ?? 0)
    }
}
