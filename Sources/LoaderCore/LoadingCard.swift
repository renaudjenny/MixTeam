import ComposableArchitecture
import SwiftUI

@Reducer
public struct LoadingCard {
    public typealias State = Void

    public enum Action: Equatable {
        case task
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}

public struct LoadingCardView: View {
    let store: StoreOf<LoadingCard>

    public init(store: StoreOf<LoadingCard>) {
        self.store = store
    }

    public var body: some View {
        ProgressView("Loading content from saved data")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task { store.send(.task) }
    }
}

#Preview {
    LoadingCardView(store: Store(initialState: ()) { LoadingCard() })
}
