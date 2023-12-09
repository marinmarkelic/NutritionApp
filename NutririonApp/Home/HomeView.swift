import SwiftUI
import ComposableArchitecture

struct HomeView: View {

    let store: StoreOf<Home>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack {
                    Text("Nutrition app")

                    Text("Items eaten today: " + "\(viewStore.numberOfMeals)")
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }

}
