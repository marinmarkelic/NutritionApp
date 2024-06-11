import Charts
import SwiftUI

struct HomeView: View {

    let chartYDomain: Int = 600
    let chartXDomain: Int = 86400 * 4 /// Number of seconds in a day times number of days
    let chartHeight: CGFloat? = 200

    @ObservedObject var presenter = HomePresenter()

    var body: some View {
        VStack {
            ScrollView {
                if let dailyNutrition = presenter.dailyNutrition {
                    chart1(for: dailyNutrition)
                }

                HStack {
                    Text(Strings.today.capitalized)
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
                Text(Strings.eatenMeals)
                    .color(emphasis: .high)
                    .shiftLeft()

                VStack(spacing: .zero) {
                    ForEach(presenter.meals) { meal in
                        MealCell(meal: meal, delete: presenter.delete)
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
            let dailyTarget = presenter.dailyTarget,
            let nutritionForToday = presenter.nutritionForToday
        {
            VStack(spacing: 16) {
                DailyCalorieCard(
                    consumedCalories: nutritionForToday.calories,
                    targetCalories: dailyTarget.calories,
                    burnedCalories: presenter.burnedCalories)

                dailyMacros(for: dailyTarget, nutrition: nutritionForToday)
            }
            .padding(8)
            .background(Color.overlay())
        }
    }

    func dailyMacros(for dailyTarget: DailyTarget, nutrition: DailyNutrition) -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(nutrition.nutrients.keys)) { nutrient in
                    macrosCard(
                        nutrient: nutrient,
                        currentValue: nutrition.nutrients[nutrient] ?? .zero,
                        targetValue: dailyTarget.nutrients[nutrient] ?? .zero,
                        color: nutrient.color)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    func macrosCard(nutrient: Nutrient, currentValue: Float, targetValue: Float, color: Color) -> some View {
        if targetValue != .zero {
            HStack {
                CircularProgressView(progress: Double(currentValue / targetValue), color: color)
                    .frame(width: 60, height: 60)

                VStack {
                    Text(nutrient.title)
                        .color(emphasis: .medium)

                    Text(Strings.intDividedByInt.formatted(Int(currentValue), Int(targetValue)))
                        .color(emphasis: .disabled)

                    +

                    Text(nutrient.unit.shortened)
                        .color(emphasis: .disabled)
                }
            }
            .padding()
            .background(Color.overlay())
        }
    }

}

struct DailyCalorieCard: View {

    let consumedCalories: Float
    let targetCalories: Float
    let burnedCalories: Int?

    private var calorieRatio: Float {
        ((consumedCalories / targetCalories) - 1) * 100
    }

    private var ratioString: String {
        if calorieRatio < 100 {
            return Strings.deficit.capitalized
        } else if calorieRatio > 100 {
            return Strings.surplus.capitalized
        } else {
            return Strings.atTarget.rawValue
        }
    }

    var body: some View {
        VStack {
            Text(Strings.calories.capitalized)
                .color(emphasis: .medium)
                .shiftLeft()
                .padding(.bottom, 8)

            HStack {
                Spacer()
                    .overlay {
                        VStack {
                            calorieInfoCell(with: consumedCalories.toInt(), title: Strings.consumed.capitalized)

                            calorieInfoCell(with: targetCalories.toInt(), title: Strings.target.capitalized)
                        }
                    }

                CalorieRatioCell(title: ratioString, value: calorieRatio.toInt())

                Spacer()
                    .overlay {
                        if let burnedCalories {
                            calorieInfoCell(with: burnedCalories, title: Strings.burned.capitalized)
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

}

// MARK: - Chart
extension HomeView {

    func chart1(for dailyNutrition: [(Int, DailyNutrition)]) -> some View {
        Chart {
            ForEach(dailyNutrition, id: \.0) { day, nutrition in
                ForEach(nutrition.nutrients.sortedByValue(andScaledTo: nutrition.calories), id: \.0) { nutrient, value in
                    BarMark(
                        x: .value("Date", .dateWithAdded(days: day), unit: .day),
                        y: .value("Calories", nutrient.baselineValue(for: value))
                    )
                    .foregroundStyle(nutrient.color)
                }
            }
        }
        .chartLegend(.visible)
        .chartYVisibleDomain(length: chartYDomain)
        .chartXVisibleDomain(length: chartXDomain)
        .chartScrollableAxes(.horizontal)
        .frame(height: chartHeight)
        .frame(maxWidth: .infinity)
        .padding()
    }

}
