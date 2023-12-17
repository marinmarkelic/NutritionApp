import Dependencies

actor StorageUseCase {

    private let service: StorageService

    init(service: StorageService) {
        self.service = service
    }

    func save(meal: MealViewModel) {
    }

    func printAll() {
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
