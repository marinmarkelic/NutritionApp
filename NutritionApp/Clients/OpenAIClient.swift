import Combine
import Foundation
import Dependencies
import SwiftOpenAI

enum QueryStatus {

    case available
    case running
    case failed

}

class OpenAIClient {

    @Dependency(\.secretsClient) private var secretsClient

    private var queryStatusSubject = CurrentValueSubject<QueryStatus, Never>(.available)
    private var conversationSubject = CurrentValueSubject<Conversation?, Never>(nil)

    var queryStatusPublisher: AnyPublisher<QueryStatus, Never> {
        queryStatusSubject.receive(on: RunLoop.main).eraseToAnyPublisher()
    }

    var conversationPublisher: AnyPublisher<Conversation?, Never> {
        conversationSubject.receive(on: RunLoop.main).eraseToAnyPublisher()
    }

    private lazy var service: OpenAIService = {
        OpenAIServiceFactory.service(apiKey: secretsClient.openAIKey)
    }()

    private lazy var nutritionAssistantId: String = {
        secretsClient.nutritionAssistantId
    }()

    func sendSingleMessage(text: String) async -> String? {
        let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text(text))], model: .gpt35Turbo)
        let chat = try? await service.startChat(parameters: parameters)

        guard let message = chat?.choices.first?.message else { return nil }

        return message.content
    }

    func send(text: String, conversationId: String?, instructions: String? = nil) async {
        queryStatusSubject.send(.running)
        appendSentMessage(text: text)

        if let conversationId {
            await sendMessage(text: text, conversationId: conversationId, instructions: instructions)
            return
        }

        guard let newThreadId = await createNewThread() else {
            queryStatusSubject.send(.failed)
            return
        }

        await sendMessage(text: text, conversationId: newThreadId, instructions: instructions)
    }

    private func appendSentMessage(text: String) {
        let conversation = conversationSubject.value ?? Conversation(id: "", assistantId: "", messages: [])
        let message = Message(id: UUID().uuidString, createdAt: 0, role: .user, text: text)
        conversationSubject.send(conversation.add(message: message))
    }

    private func createNewThread() async -> String? {
        let parameters = CreateThreadParameters()
        let thread = try? await service.createThread(parameters: parameters)
        return thread?.id
    }

    private func sendMessage(text: String, conversationId: String, instructions: String? = nil) async {
        let message = MessageParameter(role: .user, content: text)
        let _ = try? await service.createMessage(threadID: conversationId, parameters: message)
        let parameters = RunParameter(assistantID: nutritionAssistantId, instructions: instructions)

        guard let run = try? await service.createRun(threadID: conversationId, parameters: parameters) else {
            queryStatusSubject.send(.failed)
            return
        }

        await observeRun(run: run, threadId: conversationId)
    }

    func retreiveMessages(for conversationId: String) async {
        guard
            let messages = try? await service.listMessages(
                threadID: conversationId,
                limit: 20,
                order: nil,
                after: nil,
                before: nil,
                runID: nil)
        else { return }

        let conversationMessages = messages.data.map { Message(from: $0) }
        let conversation = Conversation(id: conversationId, assistantId: nutritionAssistantId, messages: conversationMessages)
        conversationSubject.send(conversation)
    }

    private func observeRun(run: RunObject, threadId: String) async {
        var counter = 0
        var runStatus = run.status
        while runStatus != "completed" {
            guard counter <= 10 else {
                queryStatusSubject.send(.failed)
                return
            }

            let run = try? await service.retrieveRun(threadID: threadId, runID: run.id)
            runStatus = run?.status ?? ""
            print("--- \(runStatus)")
            counter += 1
        }

        await retreiveMessages(for: threadId)
        queryStatusSubject.send(.available)
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
