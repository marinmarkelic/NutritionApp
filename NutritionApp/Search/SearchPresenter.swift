import Combine
import Foundation
import Dependencies

class SearchPresenter: ObservableObject {

    let query: String = ""

    @Published var meal = MealViewModel(name: "mock", date: .now, items: [])

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

//            Swift.print(meal)

            await storageUseCase.save(meal: meal)
        }
    }

    func update(servingSize: String, for nutritionItem: NutritionalItemViewModel) {
        let value = Float(servingSize) ?? 0

        meal = meal.update(servingSize: value, for: nutritionItem)
    }

    func print() {}

    func clearAll() {
        Task {
            await storageUseCase.deleteAll()
        }
    }

}
