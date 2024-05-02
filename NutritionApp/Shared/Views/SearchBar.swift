import SwiftUI

struct SearchBar: View {

    let action: (String) -> Void
    var text: Binding<String>

    init(text: Binding<String>, action: @escaping (String) -> Void) {
        self.text = text
        self.action = action
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: text)

                Circle()
                    .foregroundStyle(Color.yellow)
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        action(text.wrappedValue)
                    }
            }
            .padding(16)
            .background(Color.gray.opacity(0.2))
        }

    }

}
