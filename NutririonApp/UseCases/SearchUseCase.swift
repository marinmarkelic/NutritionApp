import Dependencies

actor SearchUseCase {

    @Dependency(\.nutritionClient)
    private var client: NutritionClient

    func search(for query: String) async -> MealViewModel {
        let viewModel = await (try? client.getNutritionalInformation(for: query)) ?? MealNetworkViewModel(items: [])

        return MealViewModel(from: viewModel, with: query)
    }

}

extension SearchUseCase: DependencyKey {

    static var liveValue: SearchUseCase {
        SearchUseCase()
    }

}

extension DependencyValues {

    var searchUseCase: SearchUseCase {
        get { self[SearchUseCase.self] }
        set { self[SearchUseCase.self] = newValue }
    }

}
