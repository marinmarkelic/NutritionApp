import CoreData
import RealmSwift

class StorageService {
    
    var coreDataStack: CoreDataStack!
    var managedContext: NSManagedObjectContext!

    var realm: Realm = try! Realm()

    init(){
        try! realm.write {
            realm.add(ComicBook())
        }
    }

    func save(meal: MealViewModel) {

    }

    @objc(ComicBook)
    class ComicBook: Object {
        @objc dynamic var title = ""
        @objc dynamic var character = ""
        @objc dynamic var issue = 0
    }

//    func addDailyNutritionItem(item: NutritionItemViewModel) -> Bool{
//        print("adding item DS")
//        var dailyNutrition: DailyNutrition
//
//
//        if fetchDailyNutrition() == nil{
//            let entity = NSEntityDescription.entity(forEntityName: "DailyNutrition", in: managedContext)!
//            dailyNutrition = DailyNutrition(entity: entity, insertInto: managedContext)
//
//            print("created new daily nutrition")
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy/MM/dd"
//            dailyNutrition.date = dateFormatter.string(from: Date())
//
////            dailyNutrition.date = Date().formatted(date: .numeric, time: .omitted)
//        }
//        else{
//            dailyNutrition = fetchDailyNutrition()!
//            print("fetched existing daily nutrition")
//        }
//
//
//        dailyNutrition.sugar_g += item.sugar_g
//        dailyNutrition.fiber_g += item.fiber_g
//        dailyNutrition.sodium_mg += item.sodium_mg
//        dailyNutrition.potassium_mg += item.potassium_mg
//        dailyNutrition.fat_saturated_g += item.fat_saturated_g
//        dailyNutrition.fat_total_g += item.fat_total_g
//        dailyNutrition.calories += item.calories
//        dailyNutrition.cholesterol_mg += item.cholesterol_mg
//        dailyNutrition.protein_g += item.protein_g
//        dailyNutrition.carbohydrates_total_g += item.carbohydrates_total_g
//
//
//        let entity = NSEntityDescription.entity(forEntityName: "DailyNutritionItem", in: managedContext)!
//        let dailyNutritionItem = DailyNutritionItem(item: item, entity: entity, insertInto: managedContext)
//        dailyNutrition.addToItems(dailyNutritionItem)
//
//        do{
//            try managedContext.save()
//            return true
//        }
//        catch let error as NSError{
//            print("Error \(error), Info: \(error.userInfo)")
//            return false
//        }
//    }


}
