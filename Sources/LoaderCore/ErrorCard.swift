import Assets
import ComposableArchitecture
import SwiftUI
import StyleCore

@Reducer
public struct ErrorCard {

    @ObservableState
    public struct State: Equatable {
        var description = ""

        public init(description: String = "") {
            self.description = description
        }
    }

    public enum Action: Equatable {
        case reload
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}

public struct ErrorCardView: View {
    let store: StoreOf<ErrorCard>

    public init(store: StoreOf<ErrorCard>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            Text(store.description)
            Button { store.send(.reload, animation: .default) } label: {
                Text("Retry")
            }
            .buttonStyle(.dashed(color: .strawberry))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundAndForeground(color: .strawberry)
    }
}

#Preview {
    ErrorCardView(store: Store(initialState: ErrorCard.State(description: "Preview Error")) {
        ErrorCard()
    })
}
