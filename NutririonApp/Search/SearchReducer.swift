import ComposableArchitecture

struct Search: Reducer {

    @Dependency(\.searchUseCase) var useCase

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .search(query):
                state.query = query

                return .run { send in
                  await send(.searchResponse(Result { await useCase.search(for: query) }))
                }
            case let .searchResponse(result):
                guard case let .success(info) = result else { return .none }

                state.meal = info
                return .none
            }
        }
    }

}
