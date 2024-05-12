import Combine
import Dependencies
import Foundation

class ChatsUseCase {

    @Dependency(\.openAIClient)
    private var client: OpenAIClient
    @Dependency(\.storageUseCase)
    private var storageUseCase: StorageUseCase

    var queryStatusPublisher: AnyPublisher<QueryStatus, Never> {
        client.queryStatusPublisher
    }

    var conversationPublisher: AnyPublisher<Conversation?, Never> {
        client.conversationPublisher
    }

    func update(_ conversation: ConversationViewModel) async {
        await storageUseCase.save(conversation: conversation)
    }

    func fetchConversations() async -> [ConversationViewModel] {
        await storageUseCase.fetchCoversations()
    }

    func switchConversation(id: String) async {
        await client.retreiveMessages(for: id)
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

            let dayString: String
            switch day {
            case 0:
                dayString = "Today:"
            case -1:
                dayString = "Yesterday:"
            default:
                dayString = "\(abs(day)) days ago:"
            }
            instruction.append(dayString)

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

        return instruction.isEmpty ? nil : nutritionInstructions + instruction
    }

}

extension ChatsUseCase {

    var nutritionInstructions: String {
"""
Act as a nutritionist. You will be provided with a list of meals that the user ate for the last few days. You should tell the user about how healthy their diet is and give some recommendations if it isn't.

Be concise, write a few sentences for each day, be more descriptive about days with unhealthy diets.

Make sure to answer any followup questions in a matter that a nutritionist would.
"""
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
