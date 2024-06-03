import SwiftUI

struct MealInformationView: View {

    private let meal: MealViewModel
    private let query: String
    private let updateServingSize: (String, NutritionalItemViewModel) -> Void
    private let updateDate: (Date) -> Void

    private var focus: FocusState<String?>.Binding
    @State private var date: Date = .now

    init(
        meal: MealViewModel,
        query: String,
        focus: FocusState<String?>.Binding,
        updateServingSize: @escaping (String, NutritionalItemViewModel) -> Void,
        updateDate: @escaping (Date) -> Void
    ) {
        self.meal = meal
        self.query = query
        self.focus = focus
        self.updateServingSize = updateServingSize
        self.updateDate = updateDate
    }

    var body: some View {
            VStack {
                MealGraphView(meal: meal)
                    .maxWidth()

                VStack(spacing: 16) {
                    element(title: Strings.amount.capitalized) {
                        ForEach(meal.items, id: \.name) { item in
                            NutritionInformationView(item: item, input: item.serving_size_g, focus: focus, updateServingSize: updateServingSize)
                                .maxWidth()
                                .tag(item.name)
                        }
                    }

                    element(title: Strings.date.capitalized) {
                        DatePicker("", selection: $date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .shiftLeft()
                    }
                }
                .padding()
                .background(Color.overlay())
            }
            .onChange(of: date) { _, newValue in
                updateDate(date)
            }
    }

    private func element<Content: View>(title: String, content: @escaping () -> Content) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .color(emphasis: .high)
                .shiftLeft()

            content()
        }
    }

}
