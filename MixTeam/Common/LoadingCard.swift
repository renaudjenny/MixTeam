import ComposableArchitecture
import SwiftUI

struct LoadingCard: ReducerProtocol {
    typealias State = Void

    enum Action: Equatable {
        case task
    }

    var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}

struct LoadingCardView: View {
    let store: StoreOf<LoadingCard>

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            ProgressView("Loading content from saved data")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .task { viewStore.send(.task) }
        }
    }
}
