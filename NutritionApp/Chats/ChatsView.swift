import SwiftUI

struct ChatsView: View {

    @ObservedObject private var presenter = ChatsPresenter()

    private let headerHeight: CGFloat = 40

    @State private var text: String = ""

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

                SearchBar(text: $text, action: { _ in })
            }

            VStack {
                header

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
            ForEach(presenter.texts) { text in
                TextCell(model: text)
            }
        }
    }

}
