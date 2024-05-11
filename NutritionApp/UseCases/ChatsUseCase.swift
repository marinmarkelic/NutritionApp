import Combine
import Dependencies
import Foundation

class ChatsUseCase {

    @Dependency(\.openAIClient)
    private var client: OpenAIClient
    @Dependency(\.storageService)
    private var storageService: StorageService
    @Dependency(\.storageUseCase)
    private var storageUseCase: StorageUseCase

    var queryStatusPublisher: AnyPublisher<QueryStatus, Never> {
        client.queryStatusPublisher
    }

    var conversationPublisher: AnyPublisher<Conversation?, Never> {
        client.conversationPublisher
    }

    func send(text: String, conversationId: String?) async {
        let instructions = await fetchDailyMealsInstructions()
        print("--- \(instructions)")

        guard let conversationId else {
            await client.send(text: text, conversationId: conversationId, instructions: instructions)
            return
        }

        await client.send(text: text, conversationId: conversationId, instructions: instructions)
    }

    private func fetchDailyMealsInstructions() async -> String? {
        let meals = await storageUseCase.fetchMeals(from: 3)

        var mealsForDaysAgo: [Int: [MealViewModel]] = [:]
        meals.forEach { meal in
            let daysAgo = meal.date.distance(from: .now, only: .day)

            guard var meals = mealsForDaysAgo[daysAgo] else {
                mealsForDaysAgo[daysAgo] = [meal]
                return
            }

            meals.append(meal)
            mealsForDaysAgo[daysAgo] = meals
        }

        return generateInstructions(for: mealsForDaysAgo)
    }

    private func generateInstructions(for meals: [Int: [MealViewModel]]) -> String? {
        var instruction = ""

        meals.keys.forEach { day in
            guard let dailyMeals = meals[day] else { return }

            instruction.append("Day \(day):")

            dailyMeals.forEach { meal in
                instruction.append(" Meal: \(meal.name), ingredients:")

                meal.items.forEach { ingredient in
                    instruction.append(" \(ingredient.serving_size_g) g of \(ingredient.name),")
                }
            }
            
            instruction.removeLast()
            instruction.append(";")
        }
        print("---1 \(instruction)")
        if !instruction.isEmpty {
            instruction.removeLast()
        }

        return instruction.isEmpty ? nil : instruction
    }

}

extension ChatsUseCase: DependencyKey {

    static var liveValue: ChatsUseCase {
        ChatsUseCase()
    }

}

extension DependencyValues {

    var chatsUseCase: ChatsUseCase {
        get { self[ChatsUseCase.self] }
        set { self[ChatsUseCase.self] = newValue }
    }

}
