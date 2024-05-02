import Charts
import SwiftUI

struct HomeView: View {

    private let chartYDomain: Int = 600
    private let chartXDomain: Int = 86400 * 4 /// Number of seconds in a day times number of days
    private let chartHeight: CGFloat? = 200

    @ObservedObject private var presenter = HomePresenter()

    private var graphGradient: Gradient {
        Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.1)])
    }

    var body: some View {
        VStack {
            ScrollView {
                if let dailyNutrition = presenter.dailyNutrition {
                    chart(for: dailyNutrition)
                }

                if let dailyTarget = presenter.dailyTarget, let nutritionForToday = presenter.nutritionForToday {
                    dailyMacros(for: dailyTarget, nutrition: nutritionForToday)
                }

                VStack(spacing: 8) {
                    Text("Eaten meals")

                    ForEach(presenter.meals) { meal in
                        MealCell(meal: meal)
                    }
                }
            }
        }
        .maxSize()
        .padding(8)
        .background(Color.background)
        .task {
            await presenter.fetchMeals()
            await presenter.fetchCalories()
        }
    }

    private func chart(for dailyNutrition: [(Int, DailyNutrition)]) -> some View {
        Chart {
            ForEach(dailyNutrition, id: \.0) { day, nutrition in
                if let targetCalories = presenter.dailyTarget?.calories {
                    LineMark(
                        x: .value("Date", .dateWithAdded(days: day), unit: .day),
                        y: .value("Calories", targetCalories),
                        series: .value("type", "Target Calories"))
                    .foregroundStyle(.blue)
                }

                LineMark(
                    x: .value("Date", .dateWithAdded(days: day), unit: .day),
                    y: .value("Calories", nutrition.calories),
                    series: .value("type", "Eaten calories"))
                .symbol(.circle)
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.yellow)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) {
                AxisValueLabel()
                    .foregroundStyle(Color.white)

                AxisGridLine()
                    .foregroundStyle(Color.white.opacity(0.2))
            }
        }
        .chartXAxis {
            AxisMarks() {
                AxisValueLabel(centered: true)
                    .foregroundStyle(Color.white)

                AxisGridLine()
                    .foregroundStyle(Color.white.opacity(0.2))
            }
        }
        .chartLegend(.visible)
        .chartYVisibleDomain(length: chartYDomain)
        .chartXVisibleDomain(length: chartXDomain)
        .chartYScale(domain: 0 ... presenter.chartHeight)
        .chartScrollableAxes(.horizontal)
        .frame(height: chartHeight)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.darkElement)
    }

    func dailyMacros(for dailyTarget: DailyTarget, nutrition: DailyNutrition) -> some View {
        ScrollView(.horizontal) {
            HStack {
                macrosCard(title: "Protein", currentValue: nutrition.protein, targetValue: dailyTarget.gramsOfProtein)

                macrosCard(title: "Fat", currentValue: nutrition.fat, targetValue: dailyTarget.gramsOfFat)

                macrosCard(title: "Carbs", currentValue: nutrition.carbohydrates, targetValue: dailyTarget.gramsOfCarbs)
            }
        }
        .scrollIndicators(.hidden)
    }

    func macrosCard(title: String, currentValue: Float, targetValue: Float) -> some View {
        HStack {
            CircularProgressView(progress: Double(currentValue / targetValue), color: .red)
                .frame(width: 60, height: 60)

            VStack {
                Text(title)

                Text("\(Int(currentValue)) / \(Int(targetValue))")
            }
        }
        .padding()
        .background(Color.element)
    }

}

struct MealCell: View {

    let meal: MealViewModel

    var body: some View {
        HStack {
            Circle()
                .foregroundStyle(Color.red)
                .frame(width: 50, height: 50)

            VStack {
                Text(meal.name)
            }
        }
        .maxWidth()
        .background(Color.element)
    }

}

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
                .font(.callout)
        }
    }

}
