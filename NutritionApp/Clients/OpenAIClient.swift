import Dependencies
import SwiftOpenAI

class OpenAIClient {

    @Dependency(\.secretsClient) private var secretsClient

    private lazy var service: OpenAIService = {
        OpenAIServiceFactory.service(apiKey: secretsClient.openAIKey)
    }()

    init() {}

    func send(text: String, conversationId: String?) async -> Conversation? {
        if let conversationId {
            return await sendMessage(text: text, conversationId: conversationId)
        }

        guard let newThreadId = await createNewThread() else { return nil }

        return await sendMessage(text: text, conversationId: newThreadId)
    }

    private func sendMessage(text: String, conversationId: String) async -> Conversation {
        let assId = "asst_IypCXensPbrrZu6ms6vZqr9o"
        let message = MessageParameter(role: .user, content: text)
        let _ = try? await service.createMessage(threadID: conversationId, parameters: message)
        let parameters = RunParameter(assistantID: assId)
        let run = try? await service.createRun(threadID: conversationId, parameters: parameters)

        var runStatus = run?.status ?? ""
        while runStatus != "completed" {
            let run = try? await service.retrieveRun(threadID: conversationId, runID: run?.id ?? "")
            runStatus = run?.status ?? ""
        }

        let messages = await retreiveMessages(for: conversationId, runId: run?.id)

        return Conversation(id: conversationId, assistantId: assId, messages: messages)
    }

    private func createNewThread() async -> String? {
        let parameters = CreateThreadParameters()
        let thread = try? await service.createThread(parameters: parameters)
        return thread?.id
    }

    private func retreiveMessages(for conversationId: String, runId: String?) async -> [Message] {
        guard
            let messages = try? await service.listMessages(
                threadID: conversationId,
                limit: 20,
                order: nil,
                after: nil,
                before: nil,
                runID: nil)
        else { return [] }

        return messages.data.map { Message(from: $0) }
    }

}

struct Conversation {

    let id: String
    let assistantId: String
    let messages: [Message]

}

struct Message: Identifiable {

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


extension OpenAIClient: DependencyKey {

    static var liveValue: OpenAIClient {
        OpenAIClient()
    }

}

extension DependencyValues {

    var openAIClient: OpenAIClient {
        get { self[OpenAIClient.self] }
        set { self[OpenAIClient.self] = newValue }
    }

}
