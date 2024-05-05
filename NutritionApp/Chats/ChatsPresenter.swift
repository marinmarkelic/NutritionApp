import SwiftUI
import Dependencies

class ChatsPresenter: ObservableObject {

    @Dependency(\.chatsUseCase)
    private var useCase: ChatsUseCase

    @Published var query: String = ""
    @Published var texts: [TextViewModel] = [
        TextViewModel(text: "This is an example text", state: .sent),
        TextViewModel(text: "This is an example text", state: .received),
        TextViewModel(text: "This is an example text", state: .received),
        TextViewModel(text: "This is an example textasdasdada sd as das dadasddasdas asd asd adsadds", state: .sent),
        TextViewModel(text: "This is an example text", state: .received),
        TextViewModel(text: "This is an example textasdasdada sd as das dadasddasdas", state: .sent),
        TextViewModel(text: "This is an example text", state: .sent)
    ]

    @MainActor
    func send() {
        let queryToSend = query
        query = ""
        texts.append(TextViewModel(text: queryToSend, state: .sent))
        Task {
            let response = await useCase.send(text: queryToSend)
            texts.append(TextViewModel(text: response, state: .received))
        }
    }

}

struct TextViewModel: Identifiable {

    enum TextState {

        case sent
        case received

    }

    let text: String
    let state: TextState
//    let timestamp: Date
//    let order: Int

    var id: String {
        UUID().uuidString
    }

}

struct Conversation
