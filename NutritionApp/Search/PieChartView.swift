import SwiftUI
import Charts

struct PieChartView: View {

    let meal: MealViewModel
    let size: CGFloat

    var body: some View {
        ZStack {
            chart
        }
        .size(with: size)
        .animation(.bouncy, value: meal)
    }

    private var chart: some View {
        Chart(meal.graphData.data) { nutrient in
            SectorMark(
                angle: .value(Text(verbatim: nutrient.title), Float(nutrient.value)),
                innerRadius: .ratio(0.4))
            .foregroundStyle(nutrient.color)
        }
    }

}
