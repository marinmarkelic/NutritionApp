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

    func fetchMeals(from daysAgo: Int) -> [MealViewModel] {
        service.fetchMeals(from: daysAgo)
    }

    func printAll() {
        service.print()
    }

    func deleteAll() {
        service.deleteAll()
    }

}

extension StorageUseCase: DependencyKey {

    static var liveValue: StorageUseCase {
        StorageUseCase()
    }

}

extension DependencyValues {

    var storageUseCase: StorageUseCase {
        get { self[StorageUseCase.self] }
        set { self[StorageUseCase.self] = newValue }
    }

}
