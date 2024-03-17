import SwiftUI
import ComposableArchitecture

struct RatingsView: View {

    let store: StoreOf<Ratings>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                Spacer()
            }
            .maxWidth()
            .padding(8)
            .background(Color.background)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }

}
