import Foundation
import ComposableArchitecture

struct Home: Reducer {

    @Dependency(\.storageUseCase) var storageUseCase

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.onMealsUpdate(Result { await storageUseCase.fetchMeals(with: .now) }))
                }
            case let .onMealsUpdate(result):
                guard case let .success(meals) = result else { return .none }

                state.meals = meals
                return .none
            }
        }
    }

}
