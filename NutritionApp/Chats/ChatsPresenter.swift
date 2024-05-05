import SwiftUI
import Dependencies

class ChatsPresenter: ObservableObject {

    @Dependency(\.chatsUseCase)
    private var useCase: ChatsUseCase

    @Published var query: String = ""
    @Published var conversation: Conversation?

    @MainActor
    func send() {
        let queryToSend = query
        query = ""
        Task {
            conversation = await useCase.send(text: queryToSend, conversationId: conversation?.id)
        }
    }

}
