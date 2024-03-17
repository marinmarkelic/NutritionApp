extension Search {

    struct State: Equatable {

        static let defaultValue = Search.State(query: "", meal: MealViewModel(name: "", date: .now, items: []))

        var query: String
        var meal: MealViewModel

    }

}
