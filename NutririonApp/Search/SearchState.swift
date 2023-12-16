extension Search {

    struct State: Equatable {

        static let defaultValue = Search.State(query: "", nutritionalItems: NutritionalItemsInformation(items: []))

        var query: String
        var nutritionalItems: NutritionalItemsInformation

    }

}
