import SwiftUI

struct SearchView: View {

    @ObservedObject private var presenter = SearchPresenter()

    @State private var query: String = ""
    @FocusState private var focus: String?

    var body: some View {
        VStack(spacing: .zero) {
                ScrollViewReader { proxy in
                    ScrollView {
                        if presenter.meal.items.count > 0 {
                            Text("\(presenter.meal.name.capitalized)")
                                .color(emphasis: .high)
                                .font(.title)
                                .shiftLeft()

                            Text("\(presenter.meal.calories.toInt()) calories")
                                .color(emphasis: .medium)
                                .shiftLeft()

                            MealInformationView(meal: presenter.meal, query: presenter.query, focus: $focus, updateServingSize: presenter.update)

                            actionsView
                        }
                    }
                    .background(Color.background)
                    .padding([.leading, .top, .trailing], 8)
                    .dismissKeyboardOnTap()
                    .onChange(of: focus) { _, value in
                        guard let value else { return }

                        proxy.scrollTo(value, anchor: .bottom)
                    }
                }

            if focus == nil {
                CustomTextField(text: $query, placeholder: "Search", icon: .search, action: presenter.search)
                    .background(Material.bar)
            }
        }
        .maxWidth()
        .background(Color.background)
        .toolbarBackground(.hidden, for: .tabBar)
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

    private var focus: FocusState<String?>.Binding

    init(meal: MealViewModel, query: String, focus: FocusState<String?>.Binding, updateServingSize: @escaping (String, NutritionalItemViewModel) -> Void) {
        self.meal = meal
        self.query = query
        self.focus = focus
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
                        NutritionInformationView(item: item, input: item.serving_size_g, focus: focus, updateServingSize: updateServingSize)
                            .maxWidth()
                            .tag(item.name)
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
    private var focus: FocusState<String?>.Binding

    init(
        item: NutritionalItemViewModel,
        input: Float,
        focus: FocusState<String?>.Binding,
        updateServingSize: @escaping (String, NutritionalItemViewModel) -> Void
    ) {
        self.item = item
        self.updateServingSize = updateServingSize
        self.focus = focus
        _input = State(initialValue: "\(input)")
    }

    var body: some View {
        HStack {
            Text("\(item.name.capitalized):")
                .color(emphasis: .medium)
                .bold()

            HStack {
                TextField("", text: $input)
                    .focused(focus, equals: item.name)
                    .foregroundStyle(Color.text(emphasis: .medium))
                    .keyboardType(.numberPad)
                    .onChange(of: input) { value in
                        updateServingSize(value, item)
                    }
                    .fixedSize(horizontal: true, vertical: false)

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
