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

    private lazy var defaults: UserDefaults = {
        UserDefaults.standard
    }()

}

// MARK: - Realm
extension StorageService {

    func save(meal: MealViewModel) {
        try! realm.write {
            realm.add(MealStorageViewModel(from: meal))
        }
    }

    func save(conversation: ConversationViewModel) {
        let conversations = realm.objects(ConversationStorageViewModel.self).filter { conversation.id == $0.id }
        guard let oldConversation = conversations.first else {
            try! realm.write {
                realm.add(ConversationStorageViewModel(from: conversation))
            }
            Swift.print("*** old")
            return
        }

        try! realm.write {
            oldConversation.lastMessage = conversation.lastMessage
            oldConversation.time = conversation.time
        }
        Swift.print("*** new")
    }

    func fetchConversations() -> [ConversationViewModel] {
        let meals = realm.objects(ConversationStorageViewModel.self)

        return meals.map { ConversationViewModel(from: $0) }
    }

    func fetchMeals(with date: Date) -> [MealViewModel] {
        let meals = realm.objects(MealStorageViewModel.self).filter {
            Calendar.current.isDateInToday($0.date)
        }

        return meals.map { MealViewModel(from: $0) }
    }

    func fetchMeals(from daysAgo: Int) -> [MealViewModel] {
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        let beginningOfToday = Calendar.current.date(from: todayComponents)!
        let beforeDate = Calendar.current.date(byAdding: .day, value: -1 * daysAgo, to: beginningOfToday)!

        let meals = realm.objects(MealStorageViewModel.self).filter { meal in
            meal.date >= beforeDate && meal.date <= beginningOfToday
        }

        return meals.map { MealViewModel(from: $0) }
    }

    func print() {
        let meals = realm.objects(MealStorageViewModel.self)

        Swift.print(meals)
    }

    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }

//        resetRealm()
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
        defaults.setValue(value, forKey: key)
    }

    func object(for key: String) -> Any? {
        defaults.object(forKey: key)
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

