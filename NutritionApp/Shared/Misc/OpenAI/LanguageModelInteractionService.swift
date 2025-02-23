import Combine
import Foundation
import Dependencies
import SwiftOpenAI

class LanguageModelInteractionService {

    @Dependency(\.secretsService) private var secretsService
    @Dependency(\.modelInstructionsService) private var modelInstructionsService

    private var queryStatusSubject = CurrentValueSubject<QueryStatus, Never>(.available)
    private var conversationSubject = CurrentValueSubject<Conversation?, Never>(nil)

    var queryStatusPublisher: AnyPublisher<QueryStatus, Never> {
        queryStatusSubject.receive(on: RunLoop.main).eraseToAnyPublisher()
    }

    var conversationPublisher: AnyPublisher<Conversation?, Never> {
        conversationSubject.receive(on: RunLoop.main).eraseToAnyPublisher()
    }

    private lazy var service: OpenAIService = {
        OpenAIServiceFactory.service(apiKey: secretsService.openAIKey)
    }()

    private lazy var nutritionAssistantId: String = {
        secretsService.nutritionAssistantId
    }()

    func sendSingleMessage(meal: String, meals: [MealViewModel]) async -> String? {
        let instructions = await modelInstructionsService.generateDailyMealsInstructions(for: meal, meals: meals)
        let parameters = ChatCompletionParameters(
            messages: [.init(role: .user, content: .text(instructions))], 
            model: .gpt35Turbo)
        let chat = try? await service.startChat(parameters: parameters)

        guard let message = chat?.choices.first?.message else { return nil }

        return message.content
    }

    func initiateMessageSending(text: String, conversationId: String?, meals: [MealViewModel]) async {
        queryStatusSubject.send(.running)
        appendSentMessage(text: text)

        let instructions = modelInstructionsService.generateChatsInstructions(for: meals)

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

    private func sendMessage(text: String, conversationId: String, instructions: String? = nil) async {
        let message = MessageParameter(role: .user, content: text)
        let _ = try? await service.createMessage(threadID: conversationId, parameters: message)

        await retreiveMessages(for: conversationId)

        let parameters = RunParameter(assistantID: nutritionAssistantId, instructions: instructions)
        guard let run = try? await service.createRun(threadID: conversationId, parameters: parameters) else {
            queryStatusSubject.send(.failed)
            return
        }

        await observeRun(run: run, threadId: conversationId)
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

    func cleanConversation() {
        conversationSubject.send(nil)
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
        let conversation = Conversation(
            id: conversationId,
            assistantId: nutritionAssistantId,
            messages: conversationMessages)
        conversationSubject.send(conversation)
    }

    private func observeRun(run: RunObject, threadId: String) async {
        Task.detached { [weak self] in
            guard let self else { return }

            let counterLimit = 10
            var counter = 0
            var runStatus = RunStatus(from: run.status)
            while runStatus.isStillRunning {
                guard counter <= counterLimit else {
                    queryStatusSubject.send(.failed)
                    return
                }

                usleep(200000)

                let run = try? await service.retrieveRun(threadID: threadId, runID: run.id)
                guard let runStatusString = run?.status else {
                    queryStatusSubject.send(.failed)
                    return
                }

                runStatus = RunStatus(from: runStatusString)
                counter += 1
            }

            await retreiveMessages(for: threadId)
            queryStatusSubject.send(.available)
        }
    }

}

extension LanguageModelInteractionService: DependencyKey {

    static var liveValue: LanguageModelInteractionService {
        LanguageModelInteractionService()
    }

}

extension DependencyValues {

    var languageModelInteractionService: LanguageModelInteractionService {
        get { self[LanguageModelInteractionService.self] }
        set { self[LanguageModelInteractionService.self] = newValue }
    }

}
