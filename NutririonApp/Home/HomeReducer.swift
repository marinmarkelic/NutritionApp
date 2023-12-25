import Foundation
import ComposableArchitecture

struct Home: Reducer {

    @Dependency(\.storageUseCase) var storageUseCase

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { _ in
                    await storageUseCase.fetchMeals(with: .now)
                }
            }
        }
    }

}
