import ComposableArchitecture
import SwiftUI

struct ErrorCard: ReducerProtocol {
    struct State: Equatable {
        var description = ""
    }

    enum Action: Equatable {
        case reload
    }

    var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}

struct ErrorCardView: View {
    let store: StoreOf<ErrorCard>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(viewStore.description)
                Button { viewStore.send(.reload, animation: .default) } label: {
                    Text("Retry")
                }
                .buttonStyle(.dashed(color: MTColor.strawberry))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundAndForeground(color: .strawberry)
        }
    }
}
