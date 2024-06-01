import SwiftUI

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
        _input = State(initialValue: "\(Int(input))")
    }

    var body: some View {
        HStack {
            Text(item.name.capitalized + ":")
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

                Text(MeasuringUnit.grams.shortened)
                    .color(emphasis: .disabled)

                Spacer()
            }
            .maxWidth()
            .background(Color.overlay())
        }
    }

}
