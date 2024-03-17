import Foundation
import Dependencies

actor StorageUseCase {

    @Dependency(\.storageService)
    private var service: StorageService

    func save(meal: MealViewModel) {
        service.save(meal: meal)
    }

    func fetchMeals(with date: Date) -> [MealViewModel] {
        service.fetchMeals(with: date)
    }

    func printAll() {
        service.print()
    }

    func deleteAll() {
        service.deleteAll()
    }

}

