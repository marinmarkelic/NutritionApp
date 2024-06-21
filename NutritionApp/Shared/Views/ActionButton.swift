import SwiftUI

struct ActionButton: View {

    let title: String
    let action: () -> Void

    var body: some View {
        Button(title) {
            action()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .foregroundStyle(Color.background)
        .background(Color.action)
        .roundCorners(radius: 4)
    }

}
