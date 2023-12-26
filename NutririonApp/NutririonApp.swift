import SwiftUI
import ComposableArchitecture

@main
struct NutririonApp: App {

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView(store: Store(initialState: Home.State(), reducer: { Home() }))
                    .tabItem { Text("Home") }

                SearchView(store: Store(initialState: Search.State.defaultValue, reducer: { Search()._printChanges() }))
                    .tabItem { Text("Search") }
            }
        }
    }

}
