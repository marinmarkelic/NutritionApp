import Foundation
import RealmSwift

class StorageService {

    var realm: Realm = try! Realm()

    func save(meal: MealViewModel) {
        try! realm.write {
            realm.add(MealStorageViewModel(from: meal))
        }
    }

    func print() {
        let meals = realm.objects(MealStorageViewModel.self)

        Swift.print(meals)
    }

}
