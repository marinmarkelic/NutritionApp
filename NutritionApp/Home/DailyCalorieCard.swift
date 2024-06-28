import SwiftUI

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
