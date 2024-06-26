import SwiftUI

struct ChatsView: View {

    private let headerHeight: CGFloat = 40

    @ObservedObject private var presenter: ChatsPresenter = ChatsPresenter()

    @State private var scrollViewHeight: CGFloat = .zero
    @State private var topSafeArea: CGFloat = .zero
    @State private var path: NavigationPath = .init()

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottom) {
                        scrollView
                    }
                    .dismissKeyboardOnTap()

                    CustomTextField(
                        text: $presenter.query,
                        placeholder: Strings.typeSomething.rawValue,
                        icon: .send,
                        isEnabled: $presenter.canSend
                    ) { _ in
                        presenter.send()
                    }
                    .background(Material.bar)
                }
                .maxSize()

                VStack {
                    header

                    if presenter.status == .failed {
                        Text(Strings.anErrorOccured)
                            .padding()
                            .background(Color.overlay())
                            .border(Color.black, width: 1)
                            .transition(.move(edge: .top))
                    }

                    Spacer()
                }
                .maxSize()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onSafeAreaChanged { insets in
                topSafeArea = insets.top
            }
            .background(Color.background)
            .toolbarBackground(.hidden, for: .tabBar)
            .animation(.easeInOut, value: presenter.isMenuShown)
//            .onAppear(perform: presenter.onAppear)
            .task {
                await presenter.onAppear()
            }
        }
    }

    private var header: some View {
        HStack {
            Text(Strings.assistant.capitalized)
                .color(emphasis: .high)
                .font(.title)

            Spacer()

            NavigationLink(
                destination: HistoryView(
                    conversations: presenter.menuConversations,
                    newConversation: presenter.newConversation,
                    switchConversation: presenter.switchConversation)
            ) {
                Image(with: .history)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.icon)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 8)
        .maxWidth()
        .frame(height: headerHeight)
        .background(Material.bar)
    }

    private var scrollView: some View {
        ScrollView(.vertical) {
            VStack {
                Color
                    .clear
                    .frame(height: topSafeArea + headerHeight)

                textsStack
                    .maxWidth()

                Color
                    .clear
                    .frame(height: 4)
            }
            .frame(minHeight: scrollViewHeight, alignment: .bottom)
        }
        .onSizeChange { size in
            scrollViewHeight = size.height
        }
        .scrollBounceBehavior(.basedOnSize)
        .defaultScrollAnchor(.bottom)
        .background(Color.background)
        .ignoresSafeArea(edges: .top)
    }

    private var textsStack: some View {
        VStack {
            if let conversation = presenter.conversation {
                ForEach(conversation.messages.reversed()) { text in
                    TextCell(model: text)
                }
            } else {
                emptyView
            }
        }
    }

    private var emptyView: some View {
        ZStack {
            Text(Strings.writeSomethingConversation)
                .color(emphasis: .disabled)
                .multilineTextAlignment(.center)
                .padding()
        }
        .maxSize()
    }

}
