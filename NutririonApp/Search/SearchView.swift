import SwiftUI
import ComposableArchitecture

struct SearchView: View {

    let store: StoreOf<Search>

    @State private var query: String = ""

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                if viewStore.nutritionalItems.items.count > 0 {
                    nutritionalInformatonView(viewStore.nutritionalItems, query: viewStore.query)
                }

                searchBar(viewStore)
            }
        }
    }

    @ViewBuilder
    private func nutritionalInformatonView(_ nutritionalItems: NutritionalItemsInformation, query: String) -> some View {
        let items = nutritionalItems.items

        ScrollView {
            VStack {
                Text("Information for \(query)")

                // Detailed info
                if items.count > 1 {

                }
            }
        }
    }

    @ViewBuilder
    private func searchBar(_ viewStore: ViewStore<Search.State, Search.Action>) -> some View {
        VStack {
            Spacer()

            HStack {
                TextField("Search", text: $query)

                Circle()
                    .foregroundStyle(Color.yellow)
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        viewStore.send(.search(query))
                    }
            }
            .padding(16)
            .background(Color.gray.opacity(0.2))
        }
    }

}
