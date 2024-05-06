import Combine
import SwiftUI
import Dependencies

class ChatsPresenter: ObservableObject {

    @Dependency(\.chatsUseCase)
    private var useCase: ChatsUseCase

    @Published var conversation: Conversation?
    @Published var query: String = ""

    private var disposables = Set<AnyCancellable>()

    var queryStatusPublisher: AnyPublisher<QueryStatus, Never> {
        useCase.queryStatusPublisher
    }

    var conversationPublisher: AnyPublisher<Conversation?, Never> {
        useCase.conversationPublisher
    }

    init() {
        bindPublishers()
    }

    @MainActor
    func send() {
        let queryToSend = query
        query = ""
        Task {
            await useCase.send(text: queryToSend, conversationId: conversation?.id)
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
