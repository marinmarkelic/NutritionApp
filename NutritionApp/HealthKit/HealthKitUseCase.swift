import Combine
import Foundation
import Dependencies

class HealthKitUseCase {

    @Dependency(\.healthKitService)
    private var service: HealthKitService

    var burntCaloriesPublisher: AnyPublisher<Double?, Never> {
        service.burntCaloriesPublisher
    }

    func userData() async -> HealthKitUserData {
        let biologicalSex = service.fetchSex()
        let sex: Sex?
        switch biologicalSex {
        case .female:
            sex = .female
        case .male:
            sex = .male
        default:
            sex = nil
        }

        let dateOfBirth = service.fetchDateOfBirth()
        let age = calculateAge(from: dateOfBirth)

        let weight = await Int(service.fetchWeight())
        let height = await Int(service.fetchHeight())

        return HealthKitUserData(sex: sex, age: age, height: height, weight: weight)
    }

    func reloadBurnedEnergy(for date: Date) {
        service.readBurnedEnergy(for: date)
    }

    private func calculateAge(from date: Date?) -> Int? {
        guard let date else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: date, to: now)
        return ageComponents.year!
    }

}

extension HealthKitUseCase: DependencyKey {

    static var liveValue: HealthKitUseCase {
        HealthKitUseCase()
    }

}

extension DependencyValues {

    var healthKitUseCase: HealthKitUseCase {
        get { self[HealthKitUseCase.self] }
        set { self[HealthKitUseCase.self] = newValue }
    }

}
