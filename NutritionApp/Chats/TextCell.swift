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
            cell(with: .chatTextQuestion)
                .background(Color.chatBubble)
                .roundCorners(radius: cornerRadius, corners: .topLeft)
                .roundCorners(radius: cornerRadius, corners: .topRight)
                .roundCorners(radius: cornerRadius, corners: .bottomLeft)
                .shiftRight()
                .padding(.horizontal)
        case .assistant:
            cell(with: .chatTextResponse)
                .background(Color.overlay(opacity: 0.2))
                .roundCorners(radius: cornerRadius, corners: .topLeft)
                .roundCorners(radius: cornerRadius, corners: .topRight)
                .roundCorners(radius: cornerRadius, corners: .bottomRight)
                .shiftLeft()
                .padding(.horizontal)
        }
    }

    private func cell(with color: Color) -> some View {
        Text(model.text)
            .font(.title3)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
    }

}
