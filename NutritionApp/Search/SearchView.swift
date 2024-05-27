import SwiftUI

struct SearchView: View {

    @ObservedObject private var presenter = SearchPresenter()

    @State private var query: String = ""

    var body: some View {
        ZStack {
            if presenter.meal.items.count > 0 {
                ScrollView {
                    Text("\(presenter.meal.name.capitalized)")
                        .color(emphasis: .high)
                        .font(.title)
                        .shiftLeft()

                    MealInformationView(meal: presenter.meal, query: presenter.query, updateServingSize: presenter.update)

                    actionsView
                }
                .background(Color.background)
                .padding([.leading, .top, .trailing], 8)
            }

            CustomTextField(text: $query, action: presenter.search)
                .background(Material.bar)
                .shiftDown()
        }
        .maxWidth()
        .background(Color.background)
        .toolbarBackground(.hidden, for: .tabBar)
        .dismissKeyboardOnTap()
        .onChange(of: presenter.meal) { newValue in
            print("--- \(newValue)")
        }
        .onAppear {
            presenter.search(query: "")
        }
    }

    var actionsView: some View {
        HStack {
            Button("Save") {
                presenter.save()
            }
            .padding(8)
            .foregroundStyle(Color.background)
            .background(Color.action)

            Button("Print") {
                presenter.print()
            }
            .backgroundStyle(Color.action)
            .padding(8)
            .foregroundStyle(Color.background)
            .background(Color.action)

            Button("Clear") {
                presenter.clearAll()
            }
            .backgroundStyle(Color.action)
            .padding(8)
            .foregroundStyle(Color.background)
            .background(Color.action)
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
                    }
                }
                .padding()
                .background(Color.overlay())
            }
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
        HStack/*(alignment: .leading)*/ {
            Text("\(item.name.capitalized):")
                .color(emphasis: .medium)
                .bold()

            HStack {
                TextField("", text: $input)
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

                Spacer()
            }
            .maxWidth()
            .background(Color.overlay())
        }
    }

}

struct NutritionCircleGraph: View {

    let meal: MealViewModel

    var body: some View {
        VStack {
            MealGraphView(meal: meal)

            Text("\(meal.calories.toInt()) calories")
                .color(emphasis: .medium)
        }
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
