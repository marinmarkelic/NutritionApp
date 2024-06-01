import SwiftUI

@main
struct NutritionApp: App {

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem { Text("Home") }

                SearchView()
                    .tabItem { Text("Search") }

                ChatsView(presenter: ChatsPresenter())
                    .tabItem { Text("Chats") }

                ProfileView()
                    .tabItem { Text("Profile") }
            }
            .toolbarBackground(.hidden, for: .tabBar)
            .environment(\.colorScheme, .dark)
        }
    }

}
