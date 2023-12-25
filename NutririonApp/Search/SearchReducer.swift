import ComposableArchitecture

struct Search: Reducer {

    @Dependency(\.searchUseCase) var searchUseCase
    @Dependency(\.storageUseCase) var storageUseCase

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .search(query):
                state.query = query

                return .run { send in
                  await send(.searchResponse(Result { await searchUseCase.search(for: query) }))
                }
            case let .searchResponse(result):
                guard case let .success(info) = result else { return .none }

                state.meal = info
                return .none
            case let .save(meal):
                return .run { _ in
                    await storageUseCase.save(meal: meal)
                }
            case .print:
                return .run { _ in
                    await storageUseCase.printAll()
                }
            case .clearAll:
                return .run { _ in
                    await storageUseCase.deleteAll()
                }
            }
        }
    }

}
