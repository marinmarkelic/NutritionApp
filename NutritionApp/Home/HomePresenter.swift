import Combine
import Dependencies

class HomePresenter: ObservableObject {

    private let chartHeightOffset: Int = 400

    @Published var meals: [MealViewModel] = []
    @Published var calories: [(Int, Int)]?
    @Published var chartHeight: Int = 0

    @Dependency(\.storageUseCase) var storageUseCase

    @MainActor
    func fetchMeals() {
        Task { [weak self] in
            guard let self else { return }

            meals = await storageUseCase.fetchMeals(from: 3)
        }
    }

    @MainActor
    func fetchCalories() {
        Task { [weak self] in
            guard let self else { return }

//            calories = await storageUseCase.fetchCalories(from: 3)
            let fetchedArray = [(0, 500), (-1, 1567), (-2, 1467)]
            calories = fetchedArray
            chartHeight = (fetchedArray.map { $0.1 }.max() ?? 0) + chartHeightOffset
        }
    }

}
