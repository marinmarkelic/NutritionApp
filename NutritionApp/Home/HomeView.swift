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
                        .color(emphasis: .high)
                        .font(.title)

                    Spacer()
                }

                todayCard

                mealsCard
            }
        }
        .maxSize()
        .padding([.leading, .top, .trailing], 8)
        .background(Color.background)
        .toolbarBackground(.visible, for: .tabBar)
        .task {
            await presenter.fetchMeals()
            await presenter.fetchCalories()
        }
    }

    @ViewBuilder
    var mealsCard: some View {
        if !presenter.meals.isEmpty {
            VStack(spacing: 8) {
                Text("Eaten meals")
                    .color(emphasis: .high)
                    .shiftLeft()

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
                .background(Color.overlay())
            }
        }
    }

}

// MARK: - Daily info
extension HomeView {

    @ViewBuilder
    var todayCard: some View {
        if
            let dailyStats = presenter.dailyStats,
            let dailyTarget = presenter.dailyTarget,
            let nutritionForToday = presenter.nutritionForToday
        {
            VStack(spacing: 16) {
                dailyCalorieCard(for: dailyStats)

                dailyMacros(for: dailyTarget, nutrition: nutritionForToday)
            }
            .padding(8)
            .background(Color.overlay())
        }
    }

    func dailyCalorieCard(for dailyStats: DailyCalorieStats) -> some View {
        VStack {
            Text("Calories")
                .color(emphasis: .medium)
                .shiftLeft()
                .padding(.bottom, 8)

            HStack {
                Spacer()
                    .overlay {
                        VStack {
                            calorieInfoCell(with: dailyStats.calories.toInt(), title: "Consumed")

                            calorieInfoCell(with: dailyStats.targetCalories.toInt(), title: "Target")
                        }
                    }

                CalorieRatioCell(title: dailyStats.ratioString, value: dailyStats.calorieRatio.toInt())

                Spacer()
                    .overlay {
                        if let calories = presenter.burnedCalories {
                            calorieInfoCell(with: calories, title: "Burned")
                        }
                    }
            }
        }
    }

    func calorieInfoCell(with value: Int, title: String) -> some View {
        VStack {
            Text("\(value)")
                .color(emphasis: .medium)
                .bold()

            Text(title)
                .color(emphasis: .disabled)
        }
    }

    func dailyMacros(for dailyTarget: DailyTarget, nutrition: DailyNutrition) -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(nutrition.nutrients.keys)) { nutrient in
                    macrosCard(
                        title: nutrient.title,
                        currentValue: nutrition.nutrients[nutrient] ?? .zero,
                        targetValue: dailyTarget.nutrients[nutrient] ?? .zero,
                        color: nutrient.color)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    func macrosCard(title: String, currentValue: Float, targetValue: Float, color: Color) -> some View {
        if targetValue != .zero {
            HStack {
                CircularProgressView(progress: Double(currentValue / targetValue), color: color)
                    .frame(width: 60, height: 60)

                VStack {
                    Text(title)
                        .color(emphasis: .medium)

                    Text("\(Int(currentValue)) / \(Int(targetValue))")
                        .color(emphasis: .disabled)
                }
            }
            .padding()
            .background(Color.overlay())
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
        .background(Color.overlay())
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
        .background(Color.overlay())
    }

}
