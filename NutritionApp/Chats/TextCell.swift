import SwiftUI

struct TextCell: View {

    let model: TextViewModel

    private let maxWidthRatio: CGFloat = 4/5

    var body: some View {
        container
    }

    @ViewBuilder
    private var container: some View {
        switch model.state {
        case .sent:
            HStack {
                Spacer()

                Text(model.text)
                    .padding()
                    .background { Color.black.opacity(0.5) }
            }
            .padding(.horizontal)
        case .received:
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
