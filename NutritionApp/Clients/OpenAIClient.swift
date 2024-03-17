import Dependencies

class OpenAIClient {

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
