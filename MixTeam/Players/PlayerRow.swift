import ComposableArchitecture
import SwiftUI

struct PlayerRow: View {
    let store: StoreOf<Player>
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        WithViewStore(store) { viewStore in
            Button { viewStore.send(.edit) } label: {
                HStack {
                    PlayerBadge(player: viewStore.state)
                        .frame(width: 80, height: 80)
                    Text(viewStore.name)
                    Spacer()
                    PlayerRowButtons(store: store)
                }
            }
            .buttonStyle(.plain)
            .listRowBackground(viewStore.color.color)
            .listRowSeparator(.hidden)
        }
    }
}

private struct PlayerRowButtons: View {
    let store: StoreOf<Player>

    var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.isStanding {
                Button { viewStore.send(.delete, animation: .easeInOut) } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .buttonStyle(.plain)
            } else {
                Button { viewStore.send(.moveBack, animation: .easeInOut) } label: {
                    Image(systemName: "gobackward")
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#if DEBUG
struct PlayerRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PlayerRow(store: .preview)
            PlayerRow(store: .preview)
        }
    }
}

extension Store where State == Player.State, Action == Player.Action {
    static var preview: Self {
        Self(initialState: .preview, reducer: Player())
    }
}
#endif
