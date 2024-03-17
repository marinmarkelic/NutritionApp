import Combine
import Dependencies

class SearchPresenter: ObservableObject {

    @Published var meal = MealViewModel(name: "mock", date: .now, items: [])
    let query: String = ""

    @Dependency(\.searchUseCase)
    private var searchUseCase: SearchUseCase
    @Dependency(\.storageUseCase)
    private var storageUseCase: StorageUseCase

    @MainActor
    func search(query: String) {
        Task { [weak self] in
            guard let self else { return }

            meal = await searchUseCase.search(for: query)
        }
    }

    func save() {
        Task { [weak self] in
            guard let self else { return }

            await storageUseCase.save(meal: meal)
        }
    }

    func print() {}

    func clearAll() {}

}
