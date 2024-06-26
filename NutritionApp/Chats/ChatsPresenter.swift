import Combine
import SwiftUI
import Dependencies

class ChatsPresenter: ObservableObject {

    @Dependency(\.chatsUseCase)
    private var chatsUseCase: ChatsUseCase

    @Published var isMenuShown: Bool = false
    @Published var menuConversations: [ConversationViewModel] = []
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
            await chatsUseCase.update(ConversationViewModel(from: conversation))
        }
    }

}

struct ConversationViewModel: Identifiable {

    let id: String
    let lastMessage: String
    let time: Int

}

extension ConversationViewModel {

    init(from model: ConversationStorageViewModel) {
        id = model.id
        lastMessage = model.lastMessage
        time = model.time
    }

    init(from model: Conversation) {
        id = model.id
        /// First is used here because messages are reversed
        lastMessage = model.messages.first?.text ?? ""
        time = model.messages.first?.createdAt ?? .zero
    }

}

extension ChatsPresenter {

    func mockChats() -> Conversation {
        let longerText =
"""
asdaaaasdad asd adasdasdasadadasdsasdas
asdasasdasdasdasda
asd
asd
asdasdasd
"""

        let messages: [Message] = [
            .init(id: "1", createdAt: 0, role: .user, text: "Hello"),
            .init(id: "2", createdAt: 0, role: .assistant, text: "Hello"),
            .init(id: "3", createdAt: 0, role: .user, text: longerText),
            .init(id: "4", createdAt: 0, role: .assistant, text: "Hello"),
            .init(id: "5", createdAt: 0, role: .user, text: "Hello"),
            .init(id: "6", createdAt: 0, role: .assistant, text: "Hello"),
            .init(id: "7", createdAt: 0, role: .user, text: "Hello"),
            .init(id: "8", createdAt: 0, role: .assistant, text: longerText),
            .init(id: "9", createdAt: 0, role: .user, text: "Hello"),
            .init(id: "10", createdAt: 0, role: .assistant, text: "Hello"),
            .init(id: "15", createdAt: 0, role: .user, text: "Hello"),
            .init(id: "16", createdAt: 0, role: .assistant, text: "Hello"),
            .init(id: "71", createdAt: 0, role: .user, text: "Hello"),
            .init(id: "21", createdAt: 0, role: .assistant, text: longerText),
            .init(id: "31", createdAt: 0, role: .user, text: longerText),
            .init(id: "41", createdAt: 0, role: .assistant, text: "Hello"),
            .init(id: "51", createdAt: 0, role: .user, text: "Hello"),
            .init(id: "61", createdAt: 0, role: .assistant, text: "Hello"),
        ]
        return Conversation(id: "", assistantId: "", messages: messages)
    }

}
