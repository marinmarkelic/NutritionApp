import SwiftUI

struct ChatsView: View {

    @ObservedObject private var presenter: ChatsPresenter
    @State private var containerSize: CGSize = .zero

    private let headerHeight: CGFloat = 40

    init(presenter: ChatsPresenter) {
        self.presenter = presenter
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    ScrollView(.vertical) {
                        textsStack
                            .maxWidth()
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .defaultScrollAnchor(.bottom)
                    .padding(.top, headerHeight)
                    .background(Color.darkElement)

                    sideMenu
                        .padding(.top, headerHeight)
                }

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
        .onSizeChange { size in
            self.containerSize = size
        }
        .maxSize()
        .background(Color.background)
        .animation(.easeInOut, value: presenter.isMenuShown)
        .onAppear(perform: presenter.onAppear)
    }

    private var header: some View {
        HStack {
            Rectangle()
                .foregroundStyle(Color.yellow)
                .frame(width: 30, height: 30)
                .onTapGesture(perform: presenter.toggleMenuVisibility)

            Text("Assistant")

            Spacer()
        }
        .padding(.horizontal, 8)
        .maxWidth()
        .frame(height: headerHeight)
        .background(Material.thin)
    }

    private var sideMenu: some View {
        HStack {
            ScrollView {
                VStack {
                    Text("New chat")
                        .onTapGesture(perform: presenter.newConversation)

                    ForEach(presenter.menuConversations) { conversation in
                        Text(conversation.lastMessage)
                            .lineLimit(3)
                            .padding()
                            .onTapGesture {
                                presenter.switchConversation(for: conversation.id)
                            }
                    }
                }
            }
            .padding()
            .ignoresSafeArea()
            .frame(width: containerSize.width * 2/3)
            .background {
                Color.background
            }

            Color
                .clear
                .maxWidth()
                .contentShape(Rectangle())
                .onTapGesture(perform: presenter.toggleMenuVisibility)
        }
        .opacity(presenter.isMenuShown ? 1 : 0)
        .maxWidth()
        .transition(.move(edge: .leading))
    }

    private var textsStack: some View {
        VStack {
            if let conversation = presenter.conversation {
                ForEach(conversation.messages.reversed()) { text in
                    TextCell(model: text)
                }
            } else {
                VStack {
                    Spacer()

                    Text("Write something to start a conversation")
                }
                .padding()
            }
        }
    }

}
