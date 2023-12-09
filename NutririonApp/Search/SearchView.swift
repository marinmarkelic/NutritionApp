import SwiftUI
import ComposableArchitecture

struct SearchView: View {

    let store: StoreOf<Search>

    @State private var query: String = ""

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    TextField("Search", text: $query)

                    Circle()
                        .foregroundStyle(Color.yellow)
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            viewStore.send(.search(query))
                        }
                }
            }
        }
    }

}
