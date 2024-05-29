import SwiftUI

struct TextCell: View {

    let model: Message

    private let cornerRadius: CGFloat = 8
    private let maxWidthRatio: CGFloat = 4/5

    var body: some View {
        container
    }

    @ViewBuilder
    private var container: some View {
        switch model.role {
        case .user:
            cell
                .background(Color.chatBubble)
                .roundCorners(radius: cornerRadius)
                .shiftRight()
                .padding(.horizontal)
        case .assistant:
            cell
                .background(Color.overlay(opacity: 0.2))
                .roundCorners(radius: cornerRadius)
                .shiftLeft()
                .padding(.horizontal)
        }
    }

    private var cell: some View {
        Text(model.text)
            .font(.title3)
            .foregroundStyle(Color.gray)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
    }

}
