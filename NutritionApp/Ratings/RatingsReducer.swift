import ComposableArchitecture

struct Ratings: Reducer {

    @Dependency(\.ratingsUseCase)
    private var useCase: RatingsUseCase

    enum Action {

        case onAppear

    }

    struct State: Equatable {

        

    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { _ in
                    await useCase.queryRatings()
                }
            }
        }
    }

}
