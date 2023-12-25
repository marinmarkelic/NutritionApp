import Foundation
import RealmSwift

class StorageService {

    private var realm: Realm {
        try! Realm()
    }

    func save(meal: MealViewModel) {
        try! realm.write {
            realm.add(MealStorageViewModel(from: meal))
        }
    }

    func fetchMeals(with date: Date) {
        let meals = realm.objects(MealStorageViewModel.self).filter {
            Calendar.current.isDateInToday($0.date)
        }

        Swift.print(meals)
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
