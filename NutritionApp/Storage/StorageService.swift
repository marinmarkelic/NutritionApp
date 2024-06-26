import Foundation
import Dependencies
import RealmSwift

class StorageService {

    private var realm: Realm {
        guard let realm = try? Realm() else {
            resetRealm()
            return try! Realm()
        }

        return realm
    }

}

// MARK: - Realm
extension StorageService {

    func save(meal: MealViewModel) {
        try! realm.write {
            let model = MealStorageViewModel(from: meal)
            realm.add(model)
        }
    }

    func delete(meal: MealViewModel) {
        guard let object = realm.object(ofType: MealStorageViewModel.self, forPrimaryKey: meal.id) else { return }

        try! realm.write {
            realm.delete(object)
        }
    }

    func save(conversation: ConversationHistoryEntry) {
        let conversations = realm.objects(ConversationStorageViewModel.self).filter { conversation.id == $0.id }
        guard let oldConversation = conversations.first else {
            try! realm.write {
                realm.add(ConversationStorageViewModel(from: conversation))
            }

            return
        }

        try! realm.write {
            oldConversation.lastMessage = conversation.lastMessage
            oldConversation.time = conversation.time
        }
    }

    func fetchConversations() -> [ConversationHistoryEntry] {
        let meals = realm.objects(ConversationStorageViewModel.self)

        return meals.map { ConversationHistoryEntry(from: $0) }
    }

    func fetchMeals(with date: Date) -> [MealViewModel] {
        let targetDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)

        let meals = realm.objects(MealStorageViewModel.self).filter {
            let mealDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: $0.date)

            let isConsumedOnTheSameDay = mealDateComponents.day == targetDateComponents.day &&
                mealDateComponents.month == targetDateComponents.month &&
                mealDateComponents.year == targetDateComponents.year

            return isConsumedOnTheSameDay
        }

        return meals.map { MealViewModel(from: $0) }
    }

    func fetchMeals(from timeline: FetchTimeline) -> [MealViewModel] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)

        guard 
            let startDate = calendar.date(byAdding: .day, value: -(timeline.days - 1), to: startOfToday),
            let endDate = calendar.date(byAdding: .second, value: 86399, to: startOfToday)
        else { return [] }

        let meals = realm.objects(MealStorageViewModel.self).filter { meal in
            meal.date >= startDate && meal.date <= endDate
        }

        return meals.map { MealViewModel(from: $0) }
    }

    private func resetRealm() {
        do {
            let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
            let realmURLs = [
                realmURL,
                realmURL.appendingPathExtension("lock"),
                realmURL.appendingPathExtension("management"),
                realmURL.appendingPathExtension("note"),
            ]

            for url in realmURLs {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            Swift.print("Error resetting Realm: \(error)")
        }
    }

}

// MARK: - UserDefaults
extension StorageService {

    func save(value: Any?, for key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
    }

    func setValuesForKeys(_ keyedValues: [String : Any]) {
        UserDefaults.standard.setValuesForKeys(keyedValues)
    }

    func object(for key: String) -> Any? {
        UserDefaults.standard.object(forKey: key)
    }

}

extension StorageService: DependencyKey {

    static var liveValue: StorageService {
        StorageService()
    }

}

extension DependencyValues {

    var storageService: StorageService {
        get { self[StorageService.self] }
        set { self[StorageService.self] = newValue }
    }

}
