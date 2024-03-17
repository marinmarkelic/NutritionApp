extension Search {

    enum Action {

        case onAppear
        case search(String)
        case searchResponse(Result<MealViewModel, Error>)
        case save(MealViewModel)
        case print
        case clearAll

    }

}
