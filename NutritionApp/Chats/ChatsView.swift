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

                HStack {
                    ScrollView {
                        VStack {
                            Text("New chat")
                            
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
                    .maxHeight()
                    .frame(width: containerSize.width * 2/3)
                    .background {
                        Color.background
                    }

                    Color
                        .clear
                        .maxWidth()
                        .contentShape(Rectangle())
                        .onTapGesture(perform: presenter.hideMenu)
                }
                .opacity(presenter.isMenuShown ? 1 : 0)
                .maxWidth()
                .transition(.move(edge: .leading))
            }
            .onSizeChange { size in
                self.containerSize = size
            }
            .maxSize()
            .background(Color.background)
            .animation(.easeInOut, value: presenter.isMenuShown)
        }
        .onAppear(perform: presenter.onAppear)
    }

    private var header: some View {
        HStack {
            Rectangle()
                .foregroundStyle(Color.yellow)
                .frame(width: 30, height: 30)
                .onTapGesture(perform: presenter.showMenu)

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
