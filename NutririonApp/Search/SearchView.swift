import SwiftUI
import ComposableArchitecture

struct SearchView: View {

    let store: StoreOf<Search>

    @State private var query: String = ""

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                if viewStore.meal.items.count > 0 {
                    nutritionalInformatonView(viewStore.meal, query: viewStore.query)
                }

                searchBar(viewStore)
            }
        }
    }

    @ViewBuilder
    private func nutritionalInformatonView(_ meal: MealViewModel, query: String) -> some View {
        let items = meal.items

        ScrollView {
            VStack {
                Text("Information for \(meal.name)")

                Text(meal.description)

                // Detailed info
                if items.count > 1 {
                    ForEach(meal.items, id: \.name) { item in
                        Text("Information for \(item.name)")

                        Text(item.description)
                    }
                }
            }
        }
    }

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
