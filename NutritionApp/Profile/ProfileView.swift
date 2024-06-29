import SwiftUI

struct ProfileView: View {

    @ObservedObject private var presenter = ProfilePresenter()

    @State var act: ActivityFrequency = .extraActive

    var body: some View {
        ScrollView {
            Text(Strings.userSettings)
                .color(emphasis: .high)
                .font(.title)
                .shiftLeft()

            VStack(spacing: 24) {
                element(title: Strings.sex.capitalized) {
                    Picker("", selection: $presenter.sex) {
                        EmptyView().tag(Optional<Sex>.none)

                        ForEach(Sex.allCases) { sex in
                            Text(sex.rawValue)
                                .tag(Optional(sex))
                        }
                    }
                    .pickerStyle(.palette)
                    .environment(\.colorScheme, .dark)
                }

                element(title: Strings.age.capitalized) {
                    TextField("", text: $presenter.age)
                        .keyboardType(.numberPad)
                        .foregroundStyle(Color.text(emphasis: .medium))
                        .padding()
                        .background(Color.overlay(opacity: 0.1))
                }

                element(title: Strings.height.capitalized) {
                    TextField("", text: $presenter.height)
                        .keyboardType(.numberPad)
                        .foregroundStyle(Color.text(emphasis: .medium))
                        .padding()
                        .background(Color.overlay(opacity: 0.1))
                }

                element(title: Strings.weight.capitalized) {
                    TextField("", text: $presenter.weight)
                        .keyboardType(.numberPad)
                        .foregroundStyle(Color.text(emphasis: .medium))
                        .padding()
                        .background(Color.overlay(opacity: 0.1))
                }

                element(title: Strings.howOftenDoYouWorkout.rawValue) {
                    Picker("", selection: $presenter.activityFrequency) {
                        Text(" - ").tag(Optional<ActivityFrequency>.none)

                        ForEach(ActivityFrequency.allCases) { activity in
                            Text(activity.description)
                                .tag(Optional(activity))
                                .colorInvert()
                        }
                    }
                    .colorMultiply(.black)
                    .colorInvert()
                    .colorMultiply(.text(emphasis: .medium))
                    .pickerStyle(.menu)
                    .environment(\.colorScheme, .dark)
                    .shiftLeft()
                }

                HStack {
                    ActionButton(title: Strings.save.capitalized) {
                        presenter.save()
                    }

                    ActionButton(title: Strings.loadFromHealth.rawValue) {
                        presenter.updateDataFromHealthKit()
                    }
                }
                .shiftRight()
            }
            .maxSize()
            .padding()
        }
        .padding([.leading, .top, .trailing], 8)
        .background(Color.background)
        .dismissKeyboardOnTap()
        .toolbarBackground(.visible, for: .tabBar)
        .onAppear() {
            presenter.onAppear()
        }
    }

    private func element<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack {
            Text(title)
                .color(emphasis: .high)
                .shiftLeft()

            content()
        }
    }

}
