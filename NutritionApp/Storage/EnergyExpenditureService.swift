import Dependencies

enum ActivityFrequency: String, CaseIterable, Identifiable {

    case sedentary = "secentary"
    case lightlyActive = "lightlyActive"
    case moderatelyActive = "moderatelyActive"
    case veryActive = "veryActive"
    case extraActive = "extraActive"

    var id: String {
        self.rawValue
    }

    var activityFactor: Float {
        switch self {
        case .sedentary:
            return 1.2
        case .lightlyActive:
            return 1.375
        case .moderatelyActive:
            return 1.55
        case .veryActive:
            return 1.725
        case .extraActive:
            return 1.9
        }
    }

    var description: String {
        switch self {
        case .sedentary:
            return "Little or no exercise."
        case .lightlyActive:
            return "1-3 days per week."
        case .moderatelyActive:
            return "3-5 days per week."
        case .veryActive:
            return "6-7 days per week."
        case .extraActive:
            return "Very hard exercise/sports & a physical job."
        }
    }

}

class EnergyExpenditureService {

    func totalDailyEnergyExpenditure(
        for sex: Sex,
        age: Int,
        height: Int,
        weight: Int,
        phisicalActivity: ActivityFrequency
    ) -> Float {
        let bmr: Float
        switch sex {
        case .female:
            bmr = 655.1 + (9.563 * Float(weight)) + (1.850 * Float(height)) - (4.676 * Float(age))
        case .male:
            bmr = 66.5 + (13.75 * Float(weight)) + (5.003 * Float(height)) - (6.75 * Float(age))
        }

        return bmr * phisicalActivity.activityFactor
    }

}

extension EnergyExpenditureService: DependencyKey {

    static var liveValue: EnergyExpenditureService {
        EnergyExpenditureService()
    }

}

extension DependencyValues {

    var energyExpenditureService: EnergyExpenditureService {
        get { self[EnergyExpenditureService.self] }
        set { self[EnergyExpenditureService.self] = newValue }
    }

}
