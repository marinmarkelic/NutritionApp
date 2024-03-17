import SwiftUI
import ComposableArchitecture

struct HomeView: View {

    let store: StoreOf<Home>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                ScrollView {
                    VStack(spacing: 8) {
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
            .maxSize()
            .padding(8)
            .background(Color.background)
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
        .maxWidth()
        .background(Color.element)
    }
}
