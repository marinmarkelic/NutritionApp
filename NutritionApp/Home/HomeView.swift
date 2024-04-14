import Charts
import SwiftUI

struct HomeView: View {

    private let chartHeight: Int = 200
    private let chartYDomain: Int = 600
    private let chartXDomain: Int = 86400 * 4 /// Number of seconds in a day times number of days

    @ObservedObject private var presenter = HomePresenter()

    private var graphGradient: Gradient {
        Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.1)])
    }

    var body: some View {
        VStack {
            ScrollView {
                if let calories = presenter.calories {
                    chart(for: calories)
                }

                VStack(spacing: 8) {
                    Text("Eaten meals")

                    ForEach(presenter.meals) { meal in
                        MealCell(meal: meal)
                    }
                }
            }
            .onAppear {
                presenter.fetchMeals()
                presenter.fetchCalories()
            }
        }
        .maxSize()
        .padding(8)
        .background(Color.background)
        .onAppear(perform: presenter.fetchMeals)
    }

    private func chart(for calories: [(Int, Int)]) -> some View {
        Chart {
            ForEach(calories, id: \.0) { day, calories in
                LineMark(
                    x: .value("Date2", .dateWithAdded(days: day), unit: .day),
                    y: .value("Calories", calories),
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
