import SwiftUI

@main
struct NutririonApp: App {

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem { Text("Home") }

                SearchView()
                    .tabItem { Text("Search") }

                RatingsView()
                    .tabItem { Text("Ratings") }
            }
        }
    }

}
