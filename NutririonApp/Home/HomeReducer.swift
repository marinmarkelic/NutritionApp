import Foundation
import ComposableArchitecture

@Reducer
struct Home {

    struct State: Equatable {

        var numberOfMeals: Int

    }

    enum Action {

        case onAppear

    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.numberOfMeals = 2
                return .none
            }
        }
    }

}
