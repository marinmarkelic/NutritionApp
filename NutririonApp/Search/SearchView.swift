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
                        VStack {
                            Text("Information for \(item.name)")

                            Text(item.description)

                            nutritionCircleGraph(item)
                                .frame(width: 200, height: 200)
                        }
                    }
                }
            }

            HStack {
                Button("Save") {
                    store.send(.save(meal))
                }

                Button("Print") {
                    store.send(.print)
                }
            }
        }
    }

    @ViewBuilder
    private func nutritionCircleGraph(_ item: NutritionalItemViewModel) -> some View {
        var progress: CGFloat = 0.0

        ZStack {
            ForEach([Nutrient.protein_g, Nutrient.carbohydrates_total_g, Nutrient.fat_total_g]) { nutrient in
                Circle()
                    .trim(from: progress, to: item.nutrients[nutrient]! / item.totalG)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 60, lineCap: .butt))

//                progress += item.nutrients[nutrient]! / item.totalG
            }
//            Circle()
//                .trim(from: progress, to: item.nutrients[.protein_g]! / item.totalG)
//                .stroke(Color.red, style: StrokeStyle(lineWidth: 60, lineCap: .butt))
//
//            Circle()
//                .trim(from: item.nutrients[.protein_g]! / item.totalG, to: item.nutrients[.carbohydrates_total_g]! / item.totalG)
//                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 60, lineCap: .butt))

        }
        .frame(width: 200 - 60, height: 200 - 60)
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
