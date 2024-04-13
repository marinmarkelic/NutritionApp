import Charts
import SwiftUI

struct HomeView: View {

    @ObservedObject private var presenter = HomePresenter()

    private var graphGradient: Gradient {
        Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.1)])
    }

    var body: some View {
        VStack {
            ScrollView {
                if let calories = presenter.calories {
                    Chart {
                        ForEach(calories, id: \.0) { day, calories in
                            LineMark(
                                x: .value("Date", .dateWithAdded(days: day), unit: .day),
                                y: .value("Caloroies", calories))
                            .symbol(.circle)
                            .interpolationMethod(.catmullRom)

                            AreaMark(
                                x: .value("Date", .dateWithAdded(days: day), unit: .day),
                                y: .value("Caloroies", calories))
                            .interpolationMethod(.catmullRom)
                            .symbol(.circle)
                            .foregroundStyle(graphGradient)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 5))
                    }
                    .chartYScale(domain: 0 ... presenter.chartHeight)
                    .chartScrollableAxes(.horizontal)
                    .chartYVisibleDomain(length: 10)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
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
