import SwiftUI

struct CustomTextField: View {

    private let action: (String) -> Void
    private let icon: BundleImage
    private let imageSize: CGFloat = 24

    private var text: Binding<String>
    private var isEnabled: Binding<Bool>

    init(
        text: Binding<String>,
        icon: BundleImage,
        isEnabled: Binding<Bool> = .constant(true),
        action: @escaping (String) -> Void) {
        self.text = text
        self.icon = icon
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: text)
                    .autocorrectionDisabled()

                Image(from: icon)
                    .resizable()
                    .size(with: imageSize)
                    .onTapGesture {
                        guard isEnabled.wrappedValue else { return }

                        action(text.wrappedValue)
                    }
            }
            .padding(16)
        }

    }

}
