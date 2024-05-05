import Dependencies
import Foundation

actor ChatsUseCase {

    @Dependency(\.openAIClient)
    private var client: OpenAIClient

    @Dependency(\.storageService)
    private var storageService: StorageService

    func send(text: String) async -> String {
        await client.send(text: text)
    }

}

extension ChatsUseCase: DependencyKey {

    static var liveValue: ChatsUseCase {
        ChatsUseCase()
    }

}

extension DependencyValues {

    var chatsUseCase: ChatsUseCase {
        get { self[ChatsUseCase.self] }
        set { self[ChatsUseCase.self] = newValue }
    }

}
