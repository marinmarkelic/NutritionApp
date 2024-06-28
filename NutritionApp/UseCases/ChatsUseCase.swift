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
        await nutritionDataUseCase.fetchCoversations().reversed()
    }

    func cleanConversation() {
        languageModelInteractionService.cleanConversation()
    }

    func switchConversation(id: String) async {
        await languageModelInteractionService.retreiveMessages(for: id)
    }

    func send(text: String, conversationId: String?) async {
        let meals = await nutritionDataUseCase.fetchMeals(from: .daysAgo(3))
        await languageModelInteractionService
            .initiateMessageSending(text: text, conversationId: conversationId, meals: meals)
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
