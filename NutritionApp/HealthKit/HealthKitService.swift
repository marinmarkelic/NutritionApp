import HealthKit
import Dependencies

class HealthKitService {

    private let store = HKHealthStore()

    private let dataTypes: Set = [
        HKQuantityType(.height),
        HKQuantityType(.bodyMass),
        HKQuantityType(.activeEnergyBurned),
        HKCharacteristicType(.biologicalSex),
        HKCharacteristicType(.dateOfBirth),
    ]

    private var canAccessData: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    init() {
        requestAccess()
    }

    func fetchSex() -> HKBiologicalSex? {
        try? store.biologicalSex().biologicalSex
    }

    func fetchDateOfBirth() -> Date? {
        try? store.dateOfBirthComponents().date
    }

    func fetchHeight() async -> Double? {
        await fetchData(for: HKQuantityType(.height))?.doubleValue(for: .meterUnit(with: .centi))
    }

    func fetchWeight() async -> Double? {
        await fetchData(for: HKQuantityType(.bodyMass))?.doubleValue(for: .gramUnit(with: .kilo))
    }

    private func fetchData(for type: HKQuantityType) async -> HKQuantity? {
        let descriptor = HKSampleQueryDescriptor(
            predicates:[.quantitySample(type: type)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1)

        guard let result = try? await descriptor.result(for: store).first else { return nil }

        return result.quantity
    }

    private func requestAccess() {
        if canAccessData {
            store.requestAuthorization(toShare: nil, read: dataTypes) {_,_ in }
        }
    }

    private func checkAuthorizationStatus() {
        for dataType in dataTypes {
            let status = store.authorizationStatus(for: dataType)
            switch status {
            case .notDetermined:
                print("\(dataType) authorization status is not determined.")
            case .sharingDenied:
                print("\(dataType) authorization status is sharing denied.")
            case .sharingAuthorized:
                print("\(dataType) authorization status is sharing authorized.")
            @unknown default:
                print("Unknown authorization status for \(dataType).")
            }
        }
    }

}

extension HealthKitService: DependencyKey {

    static var liveValue: HealthKitService {
        HealthKitService()
    }

}

extension DependencyValues {

    var healthKitService: HealthKitService {
        get { self[HealthKitService.self] }
        set { self[HealthKitService.self] = newValue }
    }

}
