import SwiftUI

extension View {

    func maxSize() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func maxWidth() -> some View {
        frame(maxWidth: .infinity)
    }

    func maxHeight() -> some View {
        frame(maxHeight: .infinity)
    }

    func size(with size: CGSize, alignment: Alignment = .center) -> some View {
        frame(width: size.width, height: size.height, alignment: alignment)
    }

    func size(with size: CGFloat, alignment: Alignment = .center) -> some View {
        frame(width: size, height: size, alignment: alignment)
    }

    func roundCorners(radius: CGFloat, corners: UIRectCorner = .allCorners) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners)).ignoresSafeArea()
    }

    func dismissKeyboardOnTap() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    func onSizeChange(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color
                    .clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }

    func onSafeAreaChanged(onChange: @escaping (EdgeInsets) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color
                    .clear
                    .preference(key: SafeAreaPreferenceKey.self, value: proxy.safeAreaInsets)
            }
        )
        .onPreferenceChange(SafeAreaPreferenceKey.self, perform: onChange)
    }

}

extension View {

    func shiftLeft(spacing: CGFloat = .zero) -> some View {
        HStack(spacing: spacing) {
            self

            Spacer()
        }
    }

    func shiftRight(spacing: CGFloat = .zero) -> some View {
        HStack(spacing: spacing) {
            Spacer()

            self
        }
    }

    func shiftUp(spacing: CGFloat = .zero) -> some View {
        VStack(spacing: spacing) {
            self

            Spacer()
        }
    }

    func shiftDown(spacing: CGFloat = .zero) -> some View {
        VStack(spacing: spacing) {
            Spacer()

            self
        }
    }

}

extension View {

    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }

}
