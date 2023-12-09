import SwiftUI
import ComposableArchitecture

@main
struct NutririonApp: App {

    var body: some Scene {
        WindowGroup {
            HomeView(store: Store(initialState: Home.State(numberOfMeals: 1), reducer: { Home()._printChanges() }))
        }
    }

}
