enum Sex: String, CaseIterable, Identifiable {

    case male = "Male"
    case female = "Female"

    var id: String {
        self.rawValue
    }

}

struct UserData {

    let sex: Sex?
    let age: Int?
    let height: Int?
    let weight: Int?
    let activityFrequency: ActivityFrequency?

}

extension UserData {

    init(model: HealthKitUserData) {
        sex = model.sex
        age = model.age
        height = model.height
        weight = model.weight
        activityFrequency = nil
    }

}
