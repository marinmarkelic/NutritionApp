import SwiftUI

struct CustomTextField: View {

    private let action: (String) -> Void
    private let placeholder: String
    private let icon: Icon
    private let imageSize: CGFloat = 24

    private var text: Binding<String>
    private var isEnabled: Binding<Bool>

    init(
        text: Binding<String>,
        placeholder: String,
        icon: Icon,
        isEnabled: Binding<Bool> = .constant(true),
        action: @escaping (String) -> Void
    ) {
        self.text = text
        self.placeholder = placeholder
        self.icon = icon
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        VStack {
            HStack {
                TextField(placeholder, text: text)
                    .autocorrectionDisabled()

                Image(with: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(isEnabled.wrappedValue ? Color.icon : Color.iconDisabled)
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
