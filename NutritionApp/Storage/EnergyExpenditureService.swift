import Dependencies

class EnergyExpenditureService {

    func totalDailyEnergyExpenditure(
        for sex: Sex,
        age: Int,
        height: Int,
        weight: Int,
        phisicalActivity: ActivityFrequency
    ) -> Float {
        let ree: Float
        switch sex {
        case .female:
            ree = 10.0 * Float(weight) + 6.25 * Float(height) - Float(5 * age) + 5.0
        case .male:
            ree = 10.0 * Float(weight) + 6.25 * Float(height) - Float(5 * age) - 161.0
        }

        return ree * phisicalActivity.activityFactor
    }

    func gramsOfProtein(for weight: Float, and age: Int) -> Float {
        switch age {
        case 1...3:
            return weight * 1.05
        case 4...13:
            return weight * 0.95
        case 14...18:
            return weight * 0.85
        case 19...:
            return weight * 0.8
        default:
            return .zero
        }
    }

    func gramsOfCarbs() -> Float {
        130
    }

    func gramsOfFat(for age: Int, and dailyCalories: Float) -> Float {
        let factor: Float
        switch age {
        case 1...3:
            factor = 0.35
        case 4...:
            factor = 0.275
        default:
            factor = .zero
        }

        let kCalsOfFat = dailyCalories * factor
        return kCalsOfFat / 9
    }

    func gramsOfFiber(for calories: Float) -> Float {
        calories * 14 / 1000
    }

    func gramsOfSugar(for calories: Float) -> Float {
        130
    }

    func milligramsOfSodium(for age: Int) -> Float {
        switch age {
        case 1...3:
            return 800
        case 4...8:
            return 1000
        case 9...18:
            return 1500
        case 19...:
            return 2300
        default:
            return .zero
        }
    }

    func milligramsOfPotassium(for age: Int, and sex: Sex) -> Float {
        switch age {
        case 1...3:
            return 2000
        case 4...8:
            return 2300
        case 9...13:
            return sex == .female ? 2300 : 2300
        case 14...18:
            return sex == .female ? 3000 : 2300
        case 19...:
            return sex == .female ? 3400 : 2600
        default:
            return .zero
        }
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
