import Combine
import Dependencies

class HomePresenter: ObservableObject {

    @Published var meals: [MealViewModel] = []

    @Dependency(\.storageUseCase) var storageUseCase

    @MainActor
    func fetchMeals() {
        Task { [weak self] in
            guard let self else { return }

            meals = await storageUseCase.fetchMeals(from: 3)
        }
    }

}
