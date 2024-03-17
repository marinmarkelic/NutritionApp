import SwiftUI

struct HomeView: View {

    @ObservedObject private var presenter = HomePresenter()

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 8) {
                    Text("Eaten meals")

                    ForEach(presenter.meals) { meal in
                        MealCell(meal: meal)
                    }
                }
            }
            .onAppear {
                presenter.fetchMeals()
            }
        }
        .maxSize()
        .padding(8)
        .background(Color.background)
        .onAppear(perform: presenter.fetchMeals)
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
