import SwiftUI
import Charts

struct MultipleCircleView: View {

    let meal: MealViewModel
    let size: CGFloat
    let strokeLineWidth: CGFloat

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
//            chart
        }
        .size(with: size)
        .animation(.bouncy, value: meal)
    }

    var chart: some View {
        Chart(meal.graphData.data) { nutrient in
                    SectorMark(
                        angle: .value(
                            Text(verbatim: "\(nutrient.color)"),
                            Float(nutrient.completion)
                        )
                    )
//                    .foregroundStyle(
//                        by: .value(
//                            Text(verbatim: product.title),
//                            product.title
//                        )
//                    )
                }
    }

}
