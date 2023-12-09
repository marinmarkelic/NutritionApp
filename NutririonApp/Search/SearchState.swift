extension Search {

    struct State: Equatable {

        static let defaultValue = Search.State(nutritionalItems: NutritionalItemsInformation(items: []))

        var nutritionalItems: NutritionalItemsInformation

    }

}
