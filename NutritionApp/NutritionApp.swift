import SwiftUI
import ComposableArchitecture

@main
struct NutritionApp: App {

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView(store: Store(initialState: Home.State(), reducer: { Home() }))
                    .tabItem { Text("Home") }

                SearchView(store: Store(initialState: Search.State.defaultValue, reducer: { Search() }))
                    .tabItem { Text("Search") }

                RatingsView(store: Store(initialState: Ratings.State(), reducer: { Ratings()._printChanges() }))
                    .tabItem { Text("Ratings") }
            }
        }
    }

}
