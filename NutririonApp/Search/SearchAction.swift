extension Search {

    enum Action {

        case onAppear
        case search(String)
        case searchResponse(Result<NutritionalItemsInformation, Error>)

    }

}
