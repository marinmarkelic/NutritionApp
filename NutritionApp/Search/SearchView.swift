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

            CustomTextField(text: $query, action: presenter.search)
        }
        .maxWidth()
        .padding(8)
        .background(Color.background)
        .dismissKeyboardOnTap()
        .onChange(of: presenter.meal) { newValue in
            print("--- \(newValue)")
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
                        .background(Color.overlay())
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

    init(item: NutritionalItemViewModel, input: Float, updateServingSize: @escaping (String, NutritionalItemViewModel) -> Void) {
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

    let meal: MealViewModel

    var body: some View {
        HStack {
            VStack {
                Text("\(meal.name)")

                MultipleCircleView(meal: meal, strokeLineWidth: 60)
                .size(with: 200)
            }
        }

        VStack {
            Text("\(meal.calories) calories")

            Text("\(meal.value(for: .protein_g)) grams of protein")
        }
    }

}

public struct MultipleCircleView: View {

    let meal: MealViewModel
    let strokeLineWidth: CGFloat

    @State var size: CGSize = .zero

    private var circleSize: CGFloat {
        let size = size.width - strokeLineWidth
        print("***2 \(size)")
        return size > .zero ? size : .zero
    }

    public var body: some View {
        ZStack {
            ForEach(meal.graphData.data, id: \.color) { data in
                Circle()
                    .trim(from: data.previousCompleton, to: data.previousCompleton + data.completion)
                    .stroke(data.color, style: StrokeStyle(lineWidth: strokeLineWidth, lineCap: .butt))
                    .frame(width: circleSize)
            }
        }
        .animation(.bouncy, value: meal)
        .maxSize()
        .onSizeChange { size in
            self.size = size
            print("***1 \(size)")
        }
    }

}
