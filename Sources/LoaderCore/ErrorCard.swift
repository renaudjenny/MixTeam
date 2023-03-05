import Assets
import ComposableArchitecture
import SwiftUI
import StyleCore

public struct ErrorCard: ReducerProtocol {
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

    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}

public struct ErrorCardView: View {
    let store: StoreOf<ErrorCard>

    public init(store: StoreOf<ErrorCard>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(viewStore.description)
                Button { viewStore.send(.reload, animation: .default) } label: {
                    Text("Retry")
                }
                .buttonStyle(.dashed(color: .strawberry))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundAndForeground(color: .strawberry)
        }
    }
}

#if DEBUG
struct ErrorCard_Previews: PreviewProvider {
    static var previews: some View {
        ErrorCardView(store: .preview)
    }
}

extension StoreOf where State == ErrorCard.State, Action == ErrorCard.Action {
    static var preview: StoreOf<ErrorCard> {
        Store(initialState: ErrorCard.State(description: "Preview Error"), reducer: ErrorCard())
    }
}
#endif
