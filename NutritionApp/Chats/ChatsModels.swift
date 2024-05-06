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
//        messages.append(message)
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
