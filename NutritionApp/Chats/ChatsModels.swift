import SwiftOpenAI

struct Conversation: Equatable {

    let id: String
    let assistantId: String
    let messages: [Message]

    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id && lhs.assistantId == rhs.assistantId && lhs.messages == rhs.messages
    }

    func add(message: Message) -> Conversation {
        var messages = messages
        messages.insert(message, at: 0)
        return Conversation(id: id, assistantId: assistantId, messages: messages)
    }

}

struct Message: Identifiable, Equatable {

    enum MessageRole: String {

        case assistant
        case user

    }

    let id: String
    let createdAt: Int
    let role: MessageRole
    let text: String

}

extension Message {

    init(from model: MessageObject) {
        id = model.id
        createdAt = model.createdAt
        role = .init(rawValue: model.role)!

        if
            let content = model.content.first,
            case MessageContent.text(let text) = content
        {
            self.text = text.text.value
        } else {
            self.text = ""
        }
    }

}

struct ConversationHistoryEntry: Identifiable {

    let id: String
    let lastMessage: String
    let time: Int

}

extension ConversationHistoryEntry {

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

