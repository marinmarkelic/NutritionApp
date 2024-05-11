import SwiftUI

struct ChatsView: View {

    @ObservedObject private var presenter: ChatsPresenter

    private let headerHeight: CGFloat = 40

    init(presenter: ChatsPresenter) {
        self.presenter = presenter
    }

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

                CustomTextField(text: $presenter.query, isEnabled: $presenter.canSend) { _ in
                    presenter.send()
                }
            }

            VStack {
                header

                if presenter.status == .failed {
                    Text("An error occured. Please try again.")
                        .padding()
                        .background(Color.element)
                        .border(Color.black, width: 1)
                        .transition(.move(edge: .top))
                }

                Spacer()
            }
        }
        .maxSize()
        .background(Color.background)
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
            if let conversation = presenter.conversation {
                ForEach(conversation.messages.reversed()) { text in
                    TextCell(model: text)
                }
            }
        }
    }

}
