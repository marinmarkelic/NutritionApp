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

    func onAppear() {
        Task {
            menuConversations = await chatsUseCase.fetchConversations()
        }
    }

    @MainActor
    func send() {
        let queryToSend = query
        query = ""
        Task {
            await chatsUseCase.send(text: queryToSend, conversationId: conversation?.id)
        }
    }

    func showMenu() {
        isMenuShown = true
    }

    func hideMenu() {
        isMenuShown = false
    }

    func switchConversation(for id: String) {
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
        guard let conversation else { return }

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
        lastMessage = model.messages.last?.text ?? ""
        time = model.messages.last?.createdAt ?? .zero
    }

}
