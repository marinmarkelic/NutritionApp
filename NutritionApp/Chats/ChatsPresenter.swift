import Combine
import SwiftUI
import Dependencies

class ChatsPresenter: ObservableObject {

    @Dependency(\.chatsUseCase)
    private var useCase: ChatsUseCase

    @Published var query: String = ""

    var queryStatusPublisher: AnyPublisher<QueryStatus, Never> {
        useCase.queryStatusPublisher
    }

    var conversationPublisher: AnyPublisher<Conversation?, Never> {
        useCase.conversationPublisher
    }

    @MainActor
    func send(id: String?) {
        let queryToSend = query
        query = ""
        Task {
            await useCase.send(text: queryToSend, conversationId: id)
        }
    }

}
