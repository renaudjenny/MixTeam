import ComposableArchitecture
import SwiftUI

public struct LoadingCard: ReducerProtocol {
    public typealias State = Void

    public enum Action: Equatable {
        case task
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}

public struct LoadingCardView: View {
    let store: StoreOf<LoadingCard>

    public init(store: StoreOf<LoadingCard>) {
        self.store = store
    }

    public var body: some View {
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
