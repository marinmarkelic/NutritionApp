import SwiftUI

@main
struct NutritionApp: App {

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .accentColor(.none)
                    .tabItem {
                        Image(with: .house)
                        Text("Home")
                    }
                    .tableStyle(.inset)

                SearchView()
                    .accentColor(.none)
                    .tabItem {
                        Image(with: .magniflyingGlass)
                        Text("Search")
                    }

                ChatsView()
                    .accentColor(.none)
                    .tabItem {
                        Image(with: .chats)
                        Text("Chats")
                    }

                ProfileView()
                    .accentColor(.none)
                    .tabItem {
                        Image(with: .profile)
                        Text("Profile")
                    }
            }
            .accentColor(.white)
            .toolbarBackground(.hidden, for: .tabBar)
            .environment(\.colorScheme, .dark)
        }
    }

}
