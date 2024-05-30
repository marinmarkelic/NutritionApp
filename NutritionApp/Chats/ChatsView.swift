import SwiftUI

struct ChatsView: View {

    private let headerHeight: CGFloat = 40

    @ObservedObject private var presenter: ChatsPresenter

    @State private var containerSize: CGSize = .zero
    @State private var topSafeArea: CGFloat = .zero

    init(presenter: ChatsPresenter) {
        self.presenter = presenter
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    scrollView

                    sideMenu
                        .padding(.top, headerHeight)
                }

                CustomTextField(text: $presenter.query, icon: .send, isEnabled: $presenter.canSend) { _ in
                    presenter.send()
                }
                .background(Material.bar)
            }

            VStack {
                header

                if presenter.status == .failed {
                    Text("An error occured. Please try again.")
                        .padding()
                        .background(Color.overlay())
                        .border(Color.black, width: 1)
                        .transition(.move(edge: .top))
                }

                Spacer()
            }
            .maxSize()
        }
        .onSizeChange { size in
            self.containerSize = size
        }
        .onSafeAreaChanged { insets in
            topSafeArea = insets.top
        }
        .background(Color.background)
        .toolbarBackground(.hidden, for: .tabBar)
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
        .background(Material.bar)
    }

    private var scrollView: some View {
        ScrollView(.vertical) {
            Color
                .clear
                .frame(height: topSafeArea + headerHeight)

            textsStack
                .maxWidth()

            Color
                .clear
                .frame(height: 4)
        }
        .scrollBounceBehavior(.basedOnSize)
        .defaultScrollAnchor(.bottom)
        .background(Color.background)
        .ignoresSafeArea(edges: .top)
    }

    private var sideMenu: some View {
        HStack {
            ScrollView {
                VStack {
                    Text("New chat")
                        .color(emphasis: .high)
                        .onTapGesture(perform: presenter.newConversation)

                    ForEach(presenter.menuConversations) { conversation in
                        Text(conversation.lastMessage)
                            .color(emphasis: .high)
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
            .background(Color.background)
            .transition(.move(edge: .leading))

            Color
                .clear
                .maxWidth()
                .contentShape(Rectangle())
                .onTapGesture(perform: presenter.toggleMenuVisibility)
        }

        .opacity(presenter.isMenuShown ? 1 : 0)
        .maxWidth()
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
