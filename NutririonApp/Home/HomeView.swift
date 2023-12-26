import SwiftUI
import ComposableArchitecture

struct HomeView: View {

    let store: StoreOf<Home>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack {
                    Text("Eaten meals")

                    ForEach(viewStore.meals) { meal in
                        MealCell(meal: meal)
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }

}

struct MealCell: View {

    let meal: MealViewModel

    var body: some View {
        HStack {
            Circle()
                .foregroundStyle(Color.red)
                .frame(width: 50, height: 50)

            VStack {
                Text(meal.name)
            }
        }
    }
}
