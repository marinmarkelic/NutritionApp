import Combine
import Dependencies

class SearchPresenter: ObservableObject {

    @Published var meal = MealViewModel(name: "mock", date: .now, items: [])
    let query: String = ""

    @Dependency(\.searchUseCase)
    private var useCase: SearchUseCase

    @MainActor
    func search(query: String) {
        Task { [weak self] in
            guard let self else { return }

            meal = await useCase.search(for: query)
        }
    }

    func save() {}

    func print() {}

    func clearAll() {}

}
