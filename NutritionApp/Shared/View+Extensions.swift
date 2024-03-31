import SwiftUI

extension View {

    func maxSize() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func maxWidth() -> some View {
        self.frame(maxWidth: .infinity)
    }

    func maxHeight() -> some View {
        self.frame(maxHeight: .infinity)
    }

    func dismissKeyboardOnTap() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

}
