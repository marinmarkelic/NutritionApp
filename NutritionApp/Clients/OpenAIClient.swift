import Dependencies
import OpenAI

class OpenAIClient {

    private let defaultModel: Model = .gpt3_5Turbo

    @Dependency(\.secretsClient) private var secretsClient

    private lazy var openAI: OpenAI = {
        OpenAI(apiToken: secretsClient.openAIKey)
    }()

    init() {}

    func send(text: String) async -> String {
        let query = ChatQuery(
            messages: [
                .init(role: .system, content: "Act as a nutritionist.")!,
                .init(role: .user, content: text)!
            ],
            model: defaultModel)
        guard let result = try? await openAI.chats(query: query) else { return "" }

        return result.choices.first!.message.content?.string ?? ""
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
