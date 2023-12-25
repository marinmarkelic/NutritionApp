import Foundation
import RealmSwift

@objc(MealStorageViewModel)
class MealStorageViewModel: Object {

    @objc dynamic var name: String = ""
    @objc dynamic var items: [NutritionalItemStorageViewModel] = []

    override init() {}

    convenience init(from model: MealViewModel) {
        self.init()
        name = model.name
        items = model.items.map { NutritionalItemStorageViewModel(from: $0) }
    }
}

@objc(NutritionalItemStorageViewModel)
class NutritionalItemStorageViewModel: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var calories: Float = .zero

    override init() {}

    convenience init(from model: NutritionalItemViewModel) {
        self.init()
        name = model.name
        calories = Float(model.calories)
    }
}
