import ComposableArchitecture

@Reducer
struct Search {

    @Dependency(\.nutritionClient) var client

    struct SearchState: Equatable {

        static let defaultValue = SearchState(nutritionalItems: NutritionalItemsInformation(items: []))

        var nutritionalItems: NutritionalItemsInformation

    }

    enum SearchAction {

        case onAppear
        case search(String)
        case searchResponse(Result<NutritionalItemsInformation, Error>)

    }

    var body: some Reducer<SearchState, SearchAction> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .search(query):
                return .run { send in
                  await send(.searchResponse(Result { try await client.nutritionalItems(query) }))
                }
            case let .searchResponse(result):
                guard case let .success(info) = result else { return .none }

                state.nutritionalItems = info
                return .none
            }
        }
    }

}
