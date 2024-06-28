import SwiftUI

struct CalorieRatioCell: View {

    let title: String
    let value: Int

    private let gradientSize = CGSize(width: 100, height: 20)
    private let markerSize = CGSize(width: 2, height: 25)

    private var markerOffset: CGSize {
        let middle = gradientSize.width / 2
        let percentageDifference = 100 + value
        let x = middle * CGFloat(percentageDifference) / 100 - markerSize.width / 2

        return CGSize(width: x, height: .zero)
    }

    var body: some View {
        VStack {
            Text(title)
                .color(emphasis: .medium)
                .bold()

            Text("\(value)%")
                .color(emphasis: .disabled)

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill (
                        LinearGradient(
                            stops: [
                                .init(color: .red, location: 0),
                                .init(color: .yellow, location: 0.3),
                                .init(color: .green, location: 0.5),
                                .init(color: .yellow, location: 0.7),
                                .init(color: .red, location: 1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing))
                    .saturation(0.9)
                    .size(with: gradientSize)

                Rectangle()
                    .foregroundColor(Color.text(emphasis: .high))
                    .size(with: markerSize)
                    .offset(markerOffset)
            }
            .animation(.bouncy(duration: 0.3, extraBounce: 0.1), value: markerOffset)
        }
    }

}
