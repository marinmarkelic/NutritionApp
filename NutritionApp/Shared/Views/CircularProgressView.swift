import SwiftUI

struct CircularProgressView: View {

    let graphProgress: Double
    let progressText: String
    let color: Color
    let lineWidth: CGFloat = 5

    init(progress: Double, color: Color) {
        self.graphProgress = progress > 1 ? 1 : progress
        self.progressText = "\(Int(progress * 100))%"
        self.color = color
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.5), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: graphProgress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text(progressText)
                .color(emphasis: .medium)
                .font(.callout)
        }
    }

}
