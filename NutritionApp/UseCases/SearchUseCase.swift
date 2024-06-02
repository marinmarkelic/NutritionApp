import Dependencies

actor SearchUseCase {

    @Dependency(\.nutritionClient)
    private var nutritionClient: NutritionClient
    @Dependency(\.openAIClient)
    private var openAIClient: OpenAIClient
    @Dependency(\.storageUseCase)
    private var storageUseCase: StorageUseCase

    func search(for query: String) async -> MealViewModel {
        let viewModel = await (try? nutritionClient.getNutritionalInformation(for: query)) ?? MealNetworkViewModel(items: [])

        return MealViewModel(from: viewModel, with: query)
    }

    func fetchOpinion(for meal: MealViewModel) async -> String? {
        let instructions = await fetchDailyMealsInstructions() + "Meal that the user wants to eat: \(meal.name)"
        print("--- " + instructions)
        return await openAIClient.sendSingleMessage(text: instructions)
    }

    private func fetchDailyMealsInstructions() async -> String {
        let meals = await storageUseCase.fetchMeals(from: 1)

        var instruction = ""
        meals.forEach { meal in
            instruction.append(" Meal: \(meal.name), ingredients:")

            meal.items.forEach { ingredient in
                print(ingredient.serving_size_g)
                instruction.append(" \(ingredient.serving_size_g) g of \(ingredient.name),")
            }
        }

        if instruction.isEmpty {
            return Strings.nutritionSearchInstructions.rawValue + "Eaten meals: none"
        } else {
            return Strings.nutritionSearchInstructions.rawValue + "Eaten meals: " + instruction
        }
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
