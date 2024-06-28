import SwiftUI

struct SearchView: View {

    @ObservedObject private var presenter = SearchPresenter()

    @State private var query: String = ""
    @State private var meal: MealViewModel?
    @FocusState private var focus: String?

    var body: some View {
        VStack(spacing: .zero) {
            if let meal {
                contentView(for: meal)
            } else {
                emptyView
            }

            if focus == nil {
                CustomTextField(text: $query, placeholder: Strings.search.capitalized, icon: .magniflyingGlass, action: presenter.search)
                    .background(Material.bar)
            }
        }
        .maxWidth()
        .animation(.easeInOut, value: presenter.opinion)
        .background(Color.background)
        .toolbarBackground(.hidden, for: .tabBar)
        .onReceive(presenter.$meal.eraseToAnyPublisher()) { meal in
            self.meal = meal
        }
    }

    private var emptyView: some View {
        ZStack {
            Color
                .clear
                .maxSize()

            Text(Strings.lookUpDesiredMeal.rawValue)
                .color(emphasis: .disabled)
                .multilineTextAlignment(.center)
                .padding()
        }
        .dismissKeyboardOnTap()
    }

    private func contentView(for meal: MealViewModel) -> some View{
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 8) {
                    Text(meal.name.capitalized)
                        .color(emphasis: .high)
                        .font(.title)
                        .shiftLeft()

                    Text(Strings.intCalories.formatted(meal.calories.toInt()))
                        .color(emphasis: .medium)
                        .shiftLeft()

                    Text(presenter.opinion ?? "")
                        .shiftLeft()

                    MealInformationView(
                        meal: meal,
                        query: presenter.query,
                        focus: $focus,
                        updateServingSize: presenter.update,
                        updateDate: presenter.update)

                    ActionButton(title: Strings.save.capitalized, action: presenter.save)
                        .shiftRight()
                }
                .padding(.bottom, 8)
            }
            .background(Color.background)
            .padding([.leading, .top, .trailing], 8)
            .dismissKeyboardOnTap()
            .onChange(of: focus) { _, value in
                guard let value else { return }

                proxy.scrollTo(value, anchor: .bottom)
            }
        }
    }

}
