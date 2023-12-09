import ComposableArchitecture

@Reducer
struct Search {

    @Dependency(\.nutritionClient) var client

    var body: some Reducer<State, Action> {
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
