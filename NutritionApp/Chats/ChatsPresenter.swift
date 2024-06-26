import Combine
import SwiftUI
import Dependencies

class ChatsPresenter: ObservableObject {

    @Dependency(\.chatsUseCase)
    private var chatsUseCase: ChatsUseCase

    @Published var isMenuShown: Bool = false
    @Published var menuConversations: [ConversationHistoryEntry] = []
    @Published var conversation: Conversation?
    @Published var query: String = ""
    @Published var canSend: Bool = true
    @Published var status: QueryStatus = .available

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
    func onAppear() async {
        self.menuConversations = await self.chatsUseCase.fetchConversations()
    }

    func send() {
        guard !query.isEmpty else { return }

        let queryToSend = query
        query = ""
        Task {
            await chatsUseCase.send(text: queryToSend, conversationId: conversation?.id)
        }
    }

    func toggleMenuVisibility() {
        isMenuShown.toggle()
    }

    func newConversation() {
        conversation = nil
    }

    func switchConversation(for id: String) {
        toggleMenuVisibility()

        Task {
            await chatsUseCase.switchConversation(id: id)
        }
    }

    private func bindPublishers() {
        conversationPublisher
            .sink { [weak self] conversation in
                guard let self else { return }

                self.conversation = conversation
                update(conversation: conversation)
            }
            .store(in: &disposables)

        queryStatusPublisher
            .sink { [weak self] status in
                guard let self else { return }

                withAnimation {
                    self.status = status
                    switch status {
                    case .available:
                        self.canSend = true
                    case .running:
                        self.canSend = false
                    case .failed:
                        self.canSend = true
                    }
                }
            }
            .store(in: &disposables)
    }

    private func update(conversation: Conversation?) {
        guard
            let conversation,
            !conversation.id.isEmpty
        else { return }

        Task {
            await chatsUseCase.update(ConversationHistoryEntry(from: conversation))
        }
    }

}
