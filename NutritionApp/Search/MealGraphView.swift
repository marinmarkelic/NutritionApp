import SwiftUI

struct MealGraphView: View {

    let meal: MealViewModel

    var body: some View {
        HStack {
            PieChartView(meal: meal, size: 200)

            VStack {
                ForEach(Array(meal.nutrients.sortedByValue(ascending: false)), id: \.0) { nutrient, value in
                    MealGraphNutrientCell(nutrient: nutrient, value: value)
                }
            }
        }
    }

}
