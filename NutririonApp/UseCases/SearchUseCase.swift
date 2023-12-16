import Dependencies

actor SearchUseCase {

    @Dependency(\.nutritionClient)
    private var client: NutritionClient

    func search(for query: String) async -> NutritionalItemsInformation {
        await (try? client.getNutritionalInformation(for: query)) ?? NutritionalItemsInformation(items: [])
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
