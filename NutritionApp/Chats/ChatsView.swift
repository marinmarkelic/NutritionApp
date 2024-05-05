import SwiftUI

struct ChatsView: View {

    @ObservedObject private var presenter = ChatsPresenter()

    @State private var conversation: Conversation?

    private let headerHeight: CGFloat = 40

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(.vertical) {
                    textsStack
                        .maxWidth()
                }
                .defaultScrollAnchor(.bottom)
                .padding(.top, headerHeight)
                .background(Color.darkElement)

                SearchBar(text: $presenter.query) { _ in
                    presenter.send(id: conversation?.id)
                }
            }

            VStack {
                header

                Spacer()
            }
        }
        .maxSize()
        .background(Color.background)
        .onReceive(presenter.conversationPublisher) { conversation in
            self.conversation = conversation
        }
        .onReceive(presenter.queryStatusPublisher) { status in
            print("--- \(status)")
        }
    }

    private var header: some View {
        HStack {
            Rectangle()
                .foregroundStyle(Color.yellow)
                .frame(width: 30, height: 30)

            Text("Assistant")

            Spacer()
        }
        .padding(.horizontal, 8)
        .maxWidth()
        .frame(height: headerHeight)
        .background(Material.thin)
    }

    private var textsStack: some View {
        VStack {
            if let conversation {
                ForEach(conversation.messages.reversed()) { text in
                    TextCell(model: text)
                }
            }
        }
    }

}
