import Combine
import Dependencies

class ProfilePresenter: ObservableObject {

    @Published var sex: Sex?
    @Published var age: String = ""
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var activityFrequency: ActivityFrequency?

    @Dependency(\.profileUseCase) private var useCase

    @MainActor
    func onAppear() {
        Task {
            let data = await useCase.fetchSavedUserData()
            sex = data.sex
            age = String(data.age ?? .zero)
            height = String(data.height ?? .zero)
            weight = String(data.weight ?? .zero)
            activityFrequency = data.activityFrequency
        }
    }

    func save() {
        Task {
            let age = Int(self.age)
            let height = Int(self.height)
            let weight = Int(self.weight)
            let data = UserData(sex: sex, age: age, height: height, weight: weight, activityFrequency: activityFrequency)
            await useCase.save(userData: data)
        }
    }

    func updateDataFromHealthKit() {
        Task {
            let data = await useCase.fetchHealthKitUserData()
            sex = data.sex
            age = String(data.age ?? .zero)
            height = String(data.height ?? .zero)
            weight = String(data.weight ?? .zero)
        }
    }

    func set(sex: Sex) {
        self.sex = sex
    }

}
