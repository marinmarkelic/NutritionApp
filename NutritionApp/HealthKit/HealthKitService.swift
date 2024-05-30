import Combine
import HealthKit
import Dependencies

class HealthKitService {

    private let store = HKHealthStore()
    private let dataTypes: Set = [
        HKQuantityType(.height),
        HKQuantityType(.bodyMass),
        HKQuantityType(.basalEnergyBurned),
        HKQuantityType(.activeEnergyBurned),
        HKCharacteristicType(.biologicalSex),
        HKCharacteristicType(.dateOfBirth),
    ]

    private var basalEnergyQuery: HKObserverQuery?
    private var activeEnergyQuery: HKObserverQuery?
    private var burntCaloriesSubject: CurrentValueSubject<Double?, Never> = CurrentValueSubject(nil)

    var burntCaloriesPublisher: AnyPublisher<Double?, Never> {
        burntCaloriesSubject.eraseToAnyPublisher()
    }

    private var canAccessData: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    init() {
        requestAccess()
        createCalorieQueries()
    }

    deinit {
        guard
            let activeEnergyQuery,
            let basalEnergyQuery
        else { return }

        store.stop(activeEnergyQuery)
        store.stop(basalEnergyQuery)
    }

    func createCalorieQueries() {
        let activeEnergyType = HKQuantityType(.activeEnergyBurned)
        let activeEnergyQuery = HKObserverQuery(sampleType: activeEnergyType, predicate: nil) { query, completionHandler, error in
            Task { [weak self] in
                guard let self else { return }

                readBurnedEnergy()
            }
        }
        self.activeEnergyQuery = activeEnergyQuery

        let basalEnergyType = HKQuantityType(.basalEnergyBurned)
        let basalEnergyQuery = HKObserverQuery(sampleType: basalEnergyType, predicate: nil) { query, completionHandler, error in
            Task { [weak self] in
                guard let self else { return }

                readBurnedEnergy()
            }
        }
        self.basalEnergyQuery = basalEnergyQuery

        store.execute(basalEnergyQuery)
    }

    func readBurnedEnergy() {
        let dispatchGroup = DispatchGroup()
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: .now, options: .strictStartDate)

        var basalEnergyBurned: Double?
        var activeEnergyBurned: Double?

        dispatchGroup.enter()
        let basalEnergyType = HKQuantityType(.basalEnergyBurned)
        let basalEnergyQuery = HKStatisticsQuery(quantityType: basalEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, _) in
            guard let result = result?.sumQuantity() else {
                dispatchGroup.leave()
                return
            }

            basalEnergyBurned = result.doubleValue(for: HKUnit.kilocalorie())
            dispatchGroup.leave()
        }
        store.execute(basalEnergyQuery)

        dispatchGroup.enter()
        let activeEnergyType = HKQuantityType(.activeEnergyBurned)
        let activeEnergyQuery = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, _) in
            guard let result = result?.sumQuantity() else {
                dispatchGroup.leave()
                return
            }

            activeEnergyBurned = result.doubleValue(for: HKUnit.kilocalorie())
            dispatchGroup.leave()
        }
        store.execute(activeEnergyQuery)

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard
                let self,
                let basalEnergyBurned,
                let activeEnergyBurned
            else { return }

            let energy = basalEnergyBurned + activeEnergyBurned
            burntCaloriesSubject.send(energy)
        }
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
