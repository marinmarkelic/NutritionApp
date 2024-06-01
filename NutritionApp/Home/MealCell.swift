import SwiftUI

struct MealCell: View {

    let meal: MealViewModel

    @State private var isExpanded: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(meal.name)
                    .color(emphasis: .medium)
                    .bold()

                label(
                    boldedText: "\(Int(meal.calories))",
                    normalText: Strings.caloriesWithDate.formatted(meal.date.formatted(date: .omitted, time: .shortened)))

                if isExpanded {
                    label(boldedText: "\(meal.value(for: .protein_g).toInt())", normalText: Strings.gramsOfProtein.rawValue)

                    label(
                        boldedText: "\(meal.value(for: .carbohydrates_total_g).toInt())",
                        normalText: Strings.gramsOfCarbs.rawValue)

                    label(boldedText: "\(meal.value(for: .fat_total_g).toInt())", normalText: Strings.gramsOfFat.rawValue)
                }
            }

            Spacer()
        }
        .maxWidth()
        .onTapGesture(perform: toggleExpansion)
    }

    private func label(boldedText: String, normalText: String) -> some View {
        Text(boldedText)
            .color(emphasis: .disabled)
            .bold()
        +
        Text(normalText)
            .color(emphasis: .disabled)
    }

    private func toggleExpansion() {
        withAnimation(.bouncy(duration: 0.25)) {
            isExpanded.toggle()
        }
    }

}
