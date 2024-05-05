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
    private var conversationSubject = PassthroughSubject<Conversation?, Never>()

    var queryStatusPublisher: AnyPublisher<QueryStatus, Never> {
        queryStatusSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    var conversationPublisher: AnyPublisher<Conversation?, Never> {
        conversationSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private lazy var service: OpenAIService = {
        OpenAIServiceFactory.service(apiKey: secretsClient.openAIKey)
    }()

    private lazy var nutritionAssistantId: String = {
        secretsClient.nutritionAssistantId
    }()

    init() {}

    func send(text: String, conversationId: String?) async {
        queryStatusSubject.send(.running)
        if let conversationId {
            await sendMessage(text: text, conversationId: conversationId)
            queryStatusSubject.send(.available)
            return
        }

        guard let newThreadId = await createNewThread() else {
            queryStatusSubject.send(.failed)
            return
        }

        await sendMessage(text: text, conversationId: newThreadId)
        queryStatusSubject.send(.available)
    }

    private func sendMessage(text: String, conversationId: String) async {
        let message = MessageParameter(role: .user, content: text)
        let _ = try? await service.createMessage(threadID: conversationId, parameters: message)
        await retreiveMessages(for: conversationId)
        let parameters = RunParameter(assistantID: nutritionAssistantId)

        guard let run = try? await service.createRun(threadID: conversationId, parameters: parameters) else {
            queryStatusSubject.send(.failed)
            return
        }

        await observeRun(run: run, threadId: conversationId)
    }

    private func createNewThread() async -> String? {
        let parameters = CreateThreadParameters()
        let thread = try? await service.createThread(parameters: parameters)
        return thread?.id
    }

    private func retreiveMessages(for conversationId: String) async {
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
            guard counter <= 5 else {
                queryStatusSubject.send(.failed)
                return
            }

            let run = try? await service.retrieveRun(threadID: threadId, runID: run.id)
            runStatus = run?.status ?? ""
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
