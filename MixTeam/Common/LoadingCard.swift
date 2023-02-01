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

#if DEBUG
struct LoadingCard_Previews: PreviewProvider {
    static var previews: some View {
        LoadingCardView(store: .preview)
    }
}

extension Store where State == Void, Action == LoadingCard.Action {
    static var preview: Store<State, Action> {
        Store(initialState: (), reducer: LoadingCard())
    }
}
#endif
