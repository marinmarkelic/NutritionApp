import Foundation
import ComposableArchitecture

struct Home: Reducer {

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
