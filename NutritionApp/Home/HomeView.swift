import Charts
import SwiftUI

struct HomeView: View {

    private let daysInChart: Int = 4
    private let chartYDomain: Int = 600
    private let chartHeight: CGFloat? = 200

    /// Number of seconds in a day times number of days
    private var chartXDomain: Int {
        86400 * daysInChart
    }

    @ObservedObject var presenter = HomePresenter()

    var body: some View {
        ZStack {
            switch presenter.state {
            case .loading:
                EmptyView()
            case .loaded:
                content
            case .empty:
                emptyView
            }
        }
        .maxSize()
        .background(Color.background)
        .toolbarBackground(.visible, for: .tabBar)
        .task {
            await presenter.onAppear()
        }
    }

    private var content: some View {
        VStack {
            ScrollView {
                VStack {
                    chart(for: presenter.dailyNutritions, isLegendVisible: presenter.isChartLegendVisible)

                    HStack {
                        Text(Strings.legend.capitalized)
                            .color(emphasis: .medium)

                        Image(with: presenter.isChartLegendVisible ? .visible : .hidden)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.icon)
                            .frame(width: 24, height: 24)
                    }
                    .padding(6)
                    .background(Color.overlay())
                    .roundCorners(radius: 8)
                    .onTapGesture {
                        withAnimation {
                            presenter.toggleLegendVisibility()
                        }
                    }
                    .shiftRight()
                }

                HStack {
                    Text(presenter.selectedDay.title)
                        .color(emphasis: .high)
                        .font(.title)

                    Spacer()
                }

                todayCard

                mealsCard
            }
        }
        .padding([.leading, .top, .trailing], 8)
    }

    @ViewBuilder
    var mealsCard: some View {
        if !presenter.selectedDayMeals.isEmpty {
            VStack(spacing: 8) {
                Text(Strings.eatenMeals)
                    .color(emphasis: .high)
                    .shiftLeft()

                VStack(spacing: .zero) {
                    ForEach(presenter.selectedDayMeals) { meal in
                        MealCell(meal: meal, delete: presenter.delete)
                            .padding(4)

                        Divider()
                            .frame(maxHeight: 1)
                            .overlay(Color.gray)
                            .opacity(presenter.selectedDayMeals.last == meal ? 0 : 1)
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
            let selectedDayNutrition = presenter.selectedDayNutrition
        {
            VStack(spacing: 16) {
                DailyCalorieCard(
                    consumedCalories: selectedDayNutrition.nutrition.calories,
                    targetCalories: selectedDayNutrition.dailyTarget.calories,
                    burnedCalories: selectedDayNutrition.burnedCalories)

                dailyMacros(for: selectedDayNutrition.dailyTarget, nutrition: selectedDayNutrition.nutrition)
            }
            .padding(8)
            .background(Color.overlay())
        }
    }

    func dailyMacros(for dailyTarget: DailyTarget, nutrition: DailyNutrition) -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(nutrition.nutrients.sortedByValue(ascending: false)), id: \.0) { nutrient, _ in
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

    private var emptyView: some View {
        ZStack {
            Text(Strings.enterAMeal)
                .color(emphasis: .disabled)
                .multilineTextAlignment(.center)
                .padding()
        }
        .maxSize()
    }

}

// MARK: - Chart
extension HomeView {

    func chart(for dailyNutrition: [(Int, DailyNutrition)], isLegendVisible: Bool) -> some View {
        HStack {
            Chart {
                ForEach(dailyNutrition, id: \.0) { day, nutrition in
                    ForEach(
                        nutrition.nutrients.sortedByValue(andScaledTo: nutrition.calories),
                        id: \.0
                    ) { nutrient, value in
                        BarMark(
                            x: .value("Date", .dateWithAdded(days: day), unit: .day),
                            y: .value("Calories", nutrient.baselineValue(for: value)))
                        .foregroundStyle(nutrient.color)
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            guard let frame = proxy.plotFrame else { return }

                            let origin = geometry[frame].origin

                            guard let date = proxy.value(atX: location.x - origin.x, as: Date.self) else { return }

                            presenter.updateDate(with: date)
                        }
                }
            }
            .chartYVisibleDomain(length: chartYDomain)
            .chartXVisibleDomain(length: chartXDomain)
            .chartScrollableAxes(.horizontal)
            .chartScrollPosition(initialX: Date.dateWithAdded(days: -daysInChart + 1))
            .frame(height: chartHeight)
            .frame(maxWidth: .infinity)
            .chartLegend(.hidden)
            .padding()

            if let selectedDayNutrition = presenter.selectedDayNutrition {
                VStack(alignment: .leading) {
                    ForEach(
                        Array(selectedDayNutrition.nutrition.nutrients.sortedByValue(ascending: false)),
                        id: \.0
                    ) { nutrient, _ in
                        HStack {
                            Circle()
                                .fill(nutrient.color)
                                .frame(width: 10, height: 10)

                            Text("\(nutrient.title)")
                                .font(.caption)
                                .color(emphasis: .medium)
                        }
                        .animation(.default, value: selectedDayNutrition.nutrition.nutrients)
                    }
                }
                .transition(.move(edge: .trailing))
                .isHidden(!isLegendVisible, remove: true)
            }
        }
    }

}
