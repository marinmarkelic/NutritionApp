import Combine
import Foundation
import Dependencies

class SearchPresenter: ObservableObject {

    let query: String = ""
    @Published var meal: MealViewModel?
    @Published var opinion: String?

    @Dependency(\.searchUseCase)
    private var useCase: SearchUseCase

    @MainActor
    func search(query: String) {
        Task { [weak self] in
            guard let self else { return }

            meal = await useCase.search(for: query)
//            self.meal = meal
            opinion = nil
            opinion = await useCase.fetchOpinion(for: meal!)
        }
    }

    func save() {
        Task { [weak self] in
            guard let self, let meal else { return }

            await useCase.save(meal: meal)
            self.meal = nil
        }
    }

    func update(servingSize: String, for nutritionItem: NutritionalItemViewModel) {
        guard let meal else { return }

        let value = Float(servingSize) ?? 0

        self.meal = meal.update(servingSize: value, for: nutritionItem)
    }

    func update(date: Date) {
        guard let meal else { return }

        self.meal = meal.update(date: date)
    }

}
