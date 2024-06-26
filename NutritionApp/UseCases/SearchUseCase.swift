import Dependencies

actor SearchUseCase {

    @Dependency(\.nutritionClient)
    private var nutritionClient: NutritionClient
    @Dependency(\.languageModelInteractionService)
    private var languageModelInteractionService: LanguageModelInteractionService
    @Dependency(\.nutritionDataUseCase)
    private var nutritionDataUseCase: NutritionDataUseCase

    func search(for query: String) async -> MealViewModel {
        let viewModel = await (try? nutritionClient.getNutritionalInformation(for: query)) ?? MealNetworkViewModel(items: [])

        return MealViewModel(from: viewModel, with: query)
    }

    func fetchOpinion(for meal: MealViewModel) async -> String? {
        let meals = await nutritionDataUseCase.fetchMeals(from: .today)
        return await languageModelInteractionService.sendSingleMessage(meal: meal.name, meals: meals)
    }

    func save(meal: MealViewModel) async {
        await nutritionDataUseCase.save(meal: meal)
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
