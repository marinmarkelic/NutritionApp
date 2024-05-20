import Charts
import SwiftUI

struct HomeView: View {

    let chartYDomain: Int = 600
    let chartXDomain: Int = 86400 * 4 /// Number of seconds in a day times number of days
    let chartHeight: CGFloat? = 200

    @ObservedObject var presenter = HomePresenter()

    private var graphGradient: Gradient {
        Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.1)])
    }

    var body: some View {
        VStack {
            ScrollView {
                if let dailyNutrition = presenter.dailyNutrition {
                    chart(for: dailyNutrition)
                }

                HStack {
                    Text("Today")
                        .font(.title)

                    Spacer()
                }

                todayCard

                VStack(spacing: 8) {
                    Text("Eaten meals")

                    VStack(spacing: .zero) {
                        ForEach(presenter.meals) { meal in
                            MealCell(meal: meal)
                                .padding(4)

                            Divider()
                                .frame(maxHeight: 1)
                                .overlay(Color.gray)
                                .opacity(presenter.meals.last == meal ? 0 : 1)
                        }
                    }
                    .padding(8)
                    .background(Color.element)
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

    var todayCard: some View {
        VStack {
            if let dailyStats = presenter.dailyStats {
                dailyCalorieCard(for: dailyStats)
            }

            if let dailyTarget = presenter.dailyTarget, let nutritionForToday = presenter.nutritionForToday {
                dailyMacros(for: dailyTarget, nutrition: nutritionForToday)
            }
        }
        .padding(8)
        .background(Color.element)
    }

    func dailyCalorieCard(for dailyStats: DailyCalorieStats) -> some View {
        HStack {
            VStack {
                VStack {
                    Text("\(dailyStats.calories.toInt())%")
                        .bold()

                    Text("Consumed")
                }

                VStack {
                    Text("\(dailyStats.targetCalories.toInt())")
                        .bold()

                    Text("Target")
                }
            }

            VStack {
                Text("\(dailyStats.calorieRatio.toInt())")
                    .bold()

                Text(dailyStats.ratioString)

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
                    .frame(width: 100, height: 20)
                //                    .size(width: 50, height: 20)
            }
        }
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
        .background(Color.darkElement)
    }

}

struct MealCell: View {

    let meal: MealViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(meal.name)
                    .bold()

                Text("\(Int(meal.calories)) calories, \(meal.date.formatted(date: .omitted, time: .shortened))")
            }

            Spacer()
        }
        .maxWidth()
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

// MARK: - Chart
extension HomeView {

    func chart(for dailyNutrition: [(Int, DailyNutrition)]) -> some View {
        Chart {
            ForEach(dailyNutrition, id: \.0) { day, nutrition in
                if let targetCalories = presenter.dailyTarget?.calories {
                    LineMark(
                        x: .value("Date", .dateWithAdded(days: day), unit: .day),
                        y: .value("Calories", targetCalories),
                        series: .value("type", "Target Calories"))
                    .symbol(.circle)
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

    func chart(for calories: [(Int, Int)]) -> some View {
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
