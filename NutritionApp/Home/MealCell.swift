import SwiftUI

struct MealCell: View {

    let meal: MealViewModel

    @State private var isExpanded: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(meal.name)
                    .bold()

                Text("\(Int(meal.calories)) calories, \(meal.date.formatted(date: .omitted, time: .shortened))")

                if isExpanded {
                    Text("\(meal.value(for: .protein_g).toInt()) grams of protein")

                    Text("\(meal.value(for: .carbohydrates_total_g).toInt()) grams of carbs")

                    Text("\(meal.value(for: .fat_total_g).toInt()) grams of fat")
                }
            }

            Spacer()
        }
        .maxWidth()
        .onTapGesture(perform: toggleExpansion)
    }

    private func toggleExpansion() {
        withAnimation(.bouncy(duration: 0.25)) {
            isExpanded.toggle()
        }
    }

}
