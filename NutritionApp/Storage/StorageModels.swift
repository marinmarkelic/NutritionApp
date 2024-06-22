import Foundation
import RealmSwift

enum FetchTimeline {

    case today
    case yesterday
    case daysAgo(Int)

    var days: Int {
        switch self {
        case .today:
            return 1
        case .yesterday:
            return 2
        case .daysAgo(let days):
            return days
        }
    }

    var date: Date? {
        Calendar.current.date(byAdding: .day, value: -days, to: Date())
    }

    init(date: Date) {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        self = .daysAgo(days)
    }

}

class ConversationStorageViewModel: Object {

    @Persisted(primaryKey: true) var id: String
    @Persisted var lastMessage: String
    @Persisted var time: Int

    override init() {}

    convenience init(from model: ConversationViewModel) {
        self.init()

        id = model.id
        lastMessage = model.lastMessage
        time = model.time
    }

}

class MealStorageViewModel: Object {

    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var date: Date
    @Persisted var items: List<NutritionalItemStorageViewModel>

    override init() {}

    convenience init(from model: MealViewModel) {
        self.init()

        id = model.id
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

extension NutritionalItemStorageViewModel {

    override var description: String {
"""
Name: \(name)
\(serving_size_g)g \(serving_size_baseline_g)g,
\(protein_g)g of protein,
\(fat_total_g)g of fat,
\(carbohydrates_total_g)g of carbs
"""
    }

}
