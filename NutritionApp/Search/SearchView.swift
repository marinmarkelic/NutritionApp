import SwiftUI

struct SearchView: View {

    @ObservedObject private var presenter = SearchPresenter()

    @State private var query: String = ""

    var body: some View {
        VStack(spacing: 0) {
            if presenter.meal.items.count > 0 {
                VStack {
                    MealInformationView(meal: presenter.meal, query: presenter.query, updateServingSize: presenter.update)

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
        .dismissKeyboardOnTap()
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
    private let updateServingSize: (String, NutritionalItemViewModel) -> Void

    init(meal: MealViewModel, query: String, updateServingSize: @escaping (String, NutritionalItemViewModel) -> Void) {
        self.meal = meal
        self.query = query
        self.updateServingSize = updateServingSize
    }

    var body: some View {
        ScrollView {
            VStack {
                NutritionCircleGraph(meal: meal)
                    .maxWidth()

                ForEach(meal.items, id: \.name) { item in
                    NutritionInformationView(item: item, input: item.serving_size_g, updateServingSize: updateServingSize)
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
    private let updateServingSize: (String, NutritionalItemViewModel) -> Void

    @State private var input: String

    init(item: NutritionalItemViewModel, input: CGFloat, updateServingSize: @escaping (String, NutritionalItemViewModel) -> Void) {
        self.item = item
        self.updateServingSize = updateServingSize
        _input = State(initialValue: "\(input)")
    }

    var body: some View {
        HStack {
            Text(item.name)

            Spacer()

            HStack {
                TextField("Amount", text: $input)
                    .keyboardType(.numberPad)
                    .onChange(of: input) { value in
                        updateServingSize(value, item)
                    }

                Text("g")
            }
        }
    }

}

struct NutritionCircleGraph: View {

    private let strokeLineWidth: CGFloat = 60

    let meal: MealViewModel

    @State var circleSize: CGFloat = 100

    var body: some View {
        HStack {
            VStack {
                Text("\(meal.name)")

                ZStack {
                    ForEach(meal.graphData.data, id: \.color) { data in
                        Circle()
                            .trim(from: data.previousCompleton, to: data.previousCompleton + data.completion)
                            .stroke(data.color, style: StrokeStyle(lineWidth: strokeLineWidth, lineCap: .butt))
                            .frame(width: circleSize)
                    }
                }
                .size(with: 200)
                .animation(.bouncy, value: meal)
                .onSizeChange { size in
                    let newCircleSize = size.width - strokeLineWidth
                    circleSize = newCircleSize > .zero ? newCircleSize : .zero
                }
            }
        }

        VStack {
            Text("\(meal.calories) calories")

            Text("\(meal.value(for: .protein_g)) grams of protein")
        }
    }

}
