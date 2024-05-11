import SwiftUI

struct CustomTextField: View {

    private let action: (String) -> Void
    private var text: Binding<String>
    private var isEnabled: Binding<Bool>

    init(text: Binding<String>, isEnabled: Binding<Bool> = .constant(true), action: @escaping (String) -> Void) {
        self.text = text
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: text)

                Circle()
                    .foregroundStyle(isEnabled.wrappedValue ? Color.yellow : Color.gray)
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        guard isEnabled.wrappedValue else { return }

                        action(text.wrappedValue)
                    }
            }
            .padding(16)
            .background(Color.gray.opacity(0.2))
        }

    }

}
