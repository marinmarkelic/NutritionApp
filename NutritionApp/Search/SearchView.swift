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

                VStack {
                    Text("Amount")
                        .color(emphasis: .high)
                        .shiftLeft()

                    ForEach(meal.items, id: \.name) { item in
                        NutritionInformationView(item: item, input: item.serving_size_g, updateServingSize: updateServingSize)
                            .maxWidth()
                            .background(Color.overlay())
                    }
                }
                .padding()
                .background(Color.overlay())
            }
        }
        .background(Color.background)
    }

}

struct NutritionInformationView: View {

    private let item: NutritionalItemViewModel
    private let updateServingSize: (String, NutritionalItemViewModel) -> Void

    @State private var input: String
    @State private var textWidth: CGFloat = .zero

    init(item: NutritionalItemViewModel, input: Float, updateServingSize: @escaping (String, NutritionalItemViewModel) -> Void) {
        self.item = item
        self.updateServingSize = updateServingSize
        _input = State(initialValue: "\(input)")
    }

    var body: some View {
        HStack {
            Text("\(item.name.capitalized):")
                .color(emphasis: .medium)
                .bold()

            HStack {
                TextField("Amount", text: $input)
                    .foregroundStyle(Color.text(emphasis: .medium))
                    .keyboardType(.numberPad)
                    .onChange(of: input) { value in
                        updateServingSize(value, item)
                    }
                    .fixedSize(horizontal: true, vertical: false)
//                    .frame(width: textWidth)
                    .overlay {
                        Text(input)
                            .hidden()
                            .fixedSize(horizontal: true, vertical: false)
//                            .onSizeChange { size in
//                                textWidth = size.width + 10
//                            }
                    }

                Text("g")
                    .color(emphasis: .disabled)
            }
        }
    }

}

struct NutritionCircleGraph: View {

    let meal: MealViewModel

    var body: some View {
        HStack {
            VStack {
                Text("\(meal.name.capitalized)")
                    .color(emphasis: .high)
                    .font(.title)
                    .shiftLeft()

                MealGraphView(meal: meal)
            }
        }

        VStack {
            Text("\(meal.calories.toInt()) calories")
                .color(emphasis: .medium)
        }
    }

}

struct MealGraphView: View {

    let meal: MealViewModel

    var body: some View {
        HStack {
            MultipleCircleView(meal: meal, size: 200, strokeLineWidth: 60)

            VStack {
                ForEach(Array(meal.nutrients.sortedByValue(ascending: false)), id: \.0) { nutrient, value in
                    nutrientCell(for: nutrient, value: value)
                }
            }
        }
    }

    private func nutrientCell(for nutrient: Nutrient, value: Float) -> some View {
        HStack {
            Circle()
                .size(with: 12)
                .foregroundStyle(nutrient.color)
                .frame(alignment: .leading)

            Text(nutrient.title)
                .color(emphasis: .medium)
                .bold()

            Text("\(value.toInt()) \(nutrient.unit.shortened)")
                .color(emphasis: .medium)
        }
        .shiftLeft()
    }

}

struct MultipleCircleView: View {

    let meal: MealViewModel
    let size: CGFloat
    let strokeLineWidth: CGFloat

//    @State var size: CGSize = .zero

    private var circleSize: CGFloat {
        let size = size - strokeLineWidth
        return size > .zero ? size : .zero
    }

    var body: some View {
        ZStack {
            ForEach(meal.graphData.data, id: \.color) { data in
                Circle()
                    .trim(from: data.previousCompleton, to: data.previousCompleton + data.completion)
                    .stroke(data.color, style: StrokeStyle(lineWidth: strokeLineWidth, lineCap: .butt))
                    .frame(width: circleSize)
            }
        }
        .size(with: size)
        .animation(.bouncy, value: meal)
//        .maxSize()
//        .onSizeChange { size in
//            self.size = size
//        }
    }

}
