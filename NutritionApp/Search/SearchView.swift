import SwiftUI

struct SearchView: View {

    @ObservedObject private var presenter = SearchPresenter()

    @State private var query: String = ""
    @FocusState private var focus: String?

    var body: some View {
        VStack(spacing: .zero) {
            if let meal = presenter.meal {
                contentView(for: meal)
            } else {
                emptyView
            }

            if focus == nil {
                CustomTextField(text: $query, placeholder: Strings.search.capitalized, icon: .search, action: presenter.search)
                    .background(Material.bar)
            }
        }
        .maxWidth()
        .animation(.easeInOut, value: presenter.opinion)
        .background(Color.background)
        .toolbarBackground(.hidden, for: .tabBar)
    }

    private var emptyView: some View {
        ZStack {
            Text(Strings.lookUpDesiredMeal.rawValue)
                .color(emphasis: .disabled)
                .multilineTextAlignment(.center)
                .padding()
        }
        .maxSize()
    }

    private func contentView(for meal: MealViewModel) -> some View{
        ScrollViewReader { proxy in
            ScrollView {
                if meal.items.count > 0 {
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

                    Button(Strings.save.rawValue) {
                        presenter.save()
                    }
                    .padding(8)
                    .foregroundStyle(Color.background)
                    .background(Color.action)
                    .shiftLeft()
                }
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
