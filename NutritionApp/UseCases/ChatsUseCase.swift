import Combine
import Dependencies
import Foundation

class ChatsUseCase {

    @Dependency(\.languageModelInteractionService)
    private var languageModelInteractionService: LanguageModelInteractionService
    @Dependency(\.nutritionDataUseCase)
    private var nutritionDataUseCase: NutritionDataUseCase

    var queryStatusPublisher: AnyPublisher<QueryStatus, Never> {
        languageModelInteractionService.queryStatusPublisher
    }

    var conversationPublisher: AnyPublisher<Conversation?, Never> {
        languageModelInteractionService.conversationPublisher
    }

    func update(_ conversation: ConversationHistoryEntry) async {
        await nutritionDataUseCase.save(conversation: conversation)
    }

    func fetchConversations() async -> [ConversationHistoryEntry] {
        await nutritionDataUseCase.fetchCoversations()
    }

    func switchConversation(id: String) async {
        await languageModelInteractionService.retreiveMessages(for: id)
    }

    func send(text: String, conversationId: String?) async {
        let instructions = await fetchDailyMealsInstructions()

        await languageModelInteractionService.initiateMessageSending(text: text, conversationId: conversationId, instructions: instructions)
    }

    private func fetchDailyMealsInstructions() async -> String? {
        let meals = await nutritionDataUseCase.fetchMeals(from: .daysAgo(3))

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

        if !instruction.isEmpty {
            instruction.removeLast()
        }

        return Strings.nutritionChatInstructions1.formatted(instruction)
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
