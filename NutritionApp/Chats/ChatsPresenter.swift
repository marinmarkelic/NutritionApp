import Combine
import SwiftUI
import Dependencies

class ChatsPresenter: ObservableObject {

    @Dependency(\.chatsUseCase)
    private var chatsUseCase: ChatsUseCase

    @Published var conversation: Conversation?
    @Published var query: String = ""

    private var disposables = Set<AnyCancellable>()

    var queryStatusPublisher: AnyPublisher<QueryStatus, Never> {
        chatsUseCase.queryStatusPublisher
    }

    var conversationPublisher: AnyPublisher<Conversation?, Never> {
        chatsUseCase.conversationPublisher
    }

    init() {
        bindPublishers()
    }

    @MainActor
    func send() {
        let queryToSend = query
        query = ""
        Task {
            await chatsUseCase.send(text: queryToSend, conversationId: conversation?.id)
        }
    }

    private func bindPublishers() {
        conversationPublisher
            .sink { [weak self] conversation in
                self?.conversation = conversation
            }
            .store(in: &disposables)

        queryStatusPublisher
            .sink { [weak self] status in
                print("--- \(status)")
            }
            .store(in: &disposables)
    }

}
