import ComposableArchitecture
import SwiftUI

struct PlayerRow: View {
    let store: StoreOf<Player>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button { viewStore.send(.edit) } label: {
                HStack {
                    PlayerBadge(player: viewStore.state)
                        .frame(width: 80, height: 80)
                    Text(viewStore.name)
                }
            }
            .listRowBackground(color: viewStore.color)
            .swipeActions(allowsFullSwipe: true) {
                if viewStore.isStanding {
                    Button(role: .destructive) { viewStore.send(.delete, animation: .easeInOut) } label: {
                        Image(systemName: "trash")
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
}

#if DEBUG
struct PlayerRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(0..<2) {
                PlayerRow(store: .preview(isStanding: $0 != 1))
            }
        }
        .listStyle(.plain)
    }
}

extension Store where State == Player.State, Action == Player.Action {
    static func preview(isStanding: Bool = false) -> Self {
        Self(initialState: .preview(isStanding: isStanding), reducer: Player())
    }
    static var preview: Self {
        .preview()
    }
}
#endif
