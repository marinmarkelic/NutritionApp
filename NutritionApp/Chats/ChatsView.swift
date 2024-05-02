import SwiftUI

struct ChatsView: View {

    @ObservedObject private var presenter = ChatsPresenter()

    @State private var text: String = ""

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {

                }
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
        .frame(height: 40)
        .background(Material.thin)
    }

}
