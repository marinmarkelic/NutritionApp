import Foundation
import Dependencies

actor StorageUseCase {

    private let service: StorageService

    init(service: StorageService) {
        self.service = service
    }

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

extension StorageUseCase: DependencyKey {

    static var liveValue: StorageUseCase {
        StorageUseCase(service: StorageService())
    }

}

extension DependencyValues {

    var storageUseCase: StorageUseCase {
        get { self[StorageUseCase.self] }
        set { self[StorageUseCase.self] = newValue }
    }

}
