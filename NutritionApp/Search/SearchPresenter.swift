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
//            // TODO: remove onAppear
//            meal = mockMeal()
        }
    }

    func save() {
        Task { [weak self] in
            guard let self else { return }

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

extension SearchPresenter {

    func mockMeal() -> MealViewModel {
        let items: [NutritionalItemViewModel] = [
            .init(from: .init(
                name: "Eggs",
                calories: 147,
                serving_size_g: 100,
                fat_total_g: 9,
                fat_saturated_g: 7,
                protein_g: 12,
                sodium_mg: 139,
                potassium_mg: 199,
                cholesterol_mg: 371,
                carbohydrates_total_g: 0.12,
                fiber_g: 0.12,
                sugar_g: 0.79)),
            .init(from: .init(
                name: "Bacon",
                calories: 466,
                serving_size_g: 100,
                fat_total_g: 34,
                fat_saturated_g: 7,
                protein_g: 34,
                sodium_mg: 1674,
                potassium_mg: 380,
                cholesterol_mg: 98,
                carbohydrates_total_g: 1.12,
                fiber_g: 0.12,
                sugar_g: 0.79)),
        ]

        return MealViewModel(
            name: "Eggs and bacon",
            date: .now,
            items: items)
    }

}
