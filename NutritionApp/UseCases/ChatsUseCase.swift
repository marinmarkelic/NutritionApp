import Combine
import Dependencies
import Foundation

class ChatsUseCase {

    @Dependency(\.openAIClient)
    private var client: OpenAIClient

    @Dependency(\.storageService)
    private var storageService: StorageService

    var queryStatusPublisher: AnyPublisher<QueryStatus, Never> {
        client.queryStatusPublisher
    }

    var conversationPublisher: AnyPublisher<Conversation?, Never> {
        client.conversationPublisher
    }

    func send(text: String, conversationId: String?) async {
        await client.send(text: text, conversationId: conversationId)
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
