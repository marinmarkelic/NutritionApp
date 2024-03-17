import SwiftUI

struct SearchView: View {

    @ObservedObject private var presenter = SearchPresenter()

    @State private var query: String = ""

    var body: some View {
        VStack(spacing: 0) {
            if presenter.meal.items.count > 0 {
                VStack {
                    MealInformationView(meal: presenter.meal, query: presenter.query)

                    HStack {
                        Button("Save") {
                            presenter.save()
                        }

                        Button("Print") {
                            presenter.print()
                        }

                        Button("Clear") {
                            presenter.clearAll()
                        }
                    }
                }
            }

            Spacer()

            searchBar()
        }
        .maxWidth()
        .padding(8)
        .background(Color.background)
    }

    private func searchBar() -> some View {
        VStack {
            HStack {
                TextField("Search", text: $query)

                Circle()
                    .foregroundStyle(Color.yellow)
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        presenter.search(query: query)
                    }
            }
            .padding(16)
            .background(Color.gray.opacity(0.2))
        }
    }

}

struct MealInformationView: View {

    private let meal: MealViewModel
    private let query: String

    init(meal: MealViewModel, query: String) {
        self.meal = meal
        self.query = query
    }

    var body: some View {
        ScrollView {
            VStack {
                ForEach(meal.items, id: \.name) { item in
                    NutritionInformationView(item: item, input: "\(item.serving_size_g)")
                        .maxWidth()
                        .background(Color.element)
                }
            }
        }
        .background(Color.background)
    }

}

struct NutritionInformationView: View {

    private let item: NutritionalItemViewModel
    @State private var input: String

    init(item: NutritionalItemViewModel, input: String) {
        self.item = item
        _input = State(initialValue: input)
    }

    var body: some View {
        VStack {
            Text("Information for \(item.name)")

            HStack {
                VStack {
                    Text(item.name)

                    NutritionCircleGraph(item: item)
                        .frame(width: 200, height: 200)
                }

                VStack {
                    Text("\(item.calories) calories")

                    Text("\(item.nutrients[.protein_g] ?? 0) grams of protein")

                    Spacer()

                    VStack {
                        Text("Serving size:")

                        HStack {
                            TextField("Amount", text: $input)


                            Text("g")
                        }
                    }
                }
            }
        }
    }

}
struct NutritionCircleGraph: View {

    let item: NutritionalItemViewModel

    var body: some View {
        ZStack {
            ForEach(item.graphData.data, id: \.color) { data in
                Circle()
                    .trim(from: data.previousCompleton, to: data.previousCompleton + data.completion)
                    .stroke(data.color, style: StrokeStyle(lineWidth: 60, lineCap: .butt))
                    .frame(width: 200 - 60, height: 200 - 60)
            }
        }
    }

}
