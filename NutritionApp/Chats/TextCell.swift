import SwiftUI

struct TextCell: View {

    let model: Message

    private let maxWidthRatio: CGFloat = 4/5

    var body: some View {
        container
    }

    @ViewBuilder
    private var container: some View {
        switch model.role {
        case .user:
            HStack {
                Spacer()

                Text(model.text)
                    .padding()
                    .background { Color.black.opacity(0.5) }
            }
            .padding(.horizontal)
        case .assistant:
            HStack {
                Text(model.text)
                    .padding()
                    .background { Color.black.opacity(0.5) }

                Spacer()
            }
            .padding(.horizontal)
        }
    }

}
