import Dependencies

class ProfileUseCase {

    @Dependency(\.nutritionDataUseCase) private var nutritionDataUseCase
    @Dependency(\.healthKitUseCase) private var healthKitUseCase

    func fetchSavedUserData() async -> UserData {
        await nutritionDataUseCase.fetchUserData()
    }

    func fetchHealthKitUserData() async -> UserData {
        let model = await healthKitUseCase.userData()
        return UserData(model: model)
    }

    func save(userData: UserData) async {
        await nutritionDataUseCase.save(userData: userData)
    }

}

extension ProfileUseCase: DependencyKey {

    static var liveValue: ProfileUseCase {
        ProfileUseCase()
    }

}

extension DependencyValues {

    var profileUseCase: ProfileUseCase {
        get { self[ProfileUseCase.self] }
        set { self[ProfileUseCase.self] = newValue }
    }

}
