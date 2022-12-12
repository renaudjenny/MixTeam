import ComposableArchitecture
import SwiftUI

struct StandingView: View {
    let store: StoreOf<Standing>

    var body: some View {
        Section {
            header
            ForEachStore(store.scope(state: \.players, action: Standing.Action.player), content: PlayerRow.init)
        }
    }

    private var header: some View {
        WithViewStore(store) { viewStore in
            Group {
                switch viewStore.playersState {
                case .loading:
                    Text("Players standing for a team")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .task { @MainActor in viewStore.send(.load) }
                case .loaded:
                    VStack {
                        Text("Players standing for a team")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Button { viewStore.send(.createPlayer, animation: .easeInOut) } label: {
                            Label { Text("Add Player") } icon: {
                                HStack {
                                    Image(systemName: "person.3")
                                    Image(systemName: "plus")
                                }
                                .font(.title3)
                            }
                            .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.dashed(color: .aluminium))
                    }
                case .error:
                    Text("Error!")
                }
            }
            .frame(maxWidth: .infinity)
            .backgroundAndForeground(color: .aluminium)
        }
    }
}

#if DEBUG
struct FirstTeamRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            StandingView(store: .preview)
        }
        .listStyle(.plain)
        .listRowSeparator(.hidden)
    }
}

extension Store where State == Standing.State, Action == Standing.Action {
    static var preview: Self {
        Self(initialState: .preview, reducer: Standing())
    }
}

private extension Standing.State {
    static var preview: Self {
        Standing.State(
            players: [Player.State(id: UUID(), name: "Player 1", image: .amelie, color: .aluminium, isStanding: true)]
        )
    }
}
#endif
