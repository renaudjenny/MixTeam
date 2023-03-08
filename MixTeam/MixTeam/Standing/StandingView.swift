import ComposableArchitecture
import PlayersFeature
import SwiftUI
import TeamsCore

struct StandingView: View {
    let store: StoreOf<Standing>

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            Section {
                header
                ForEachStore(store.scope(state: \.players, action: Standing.Action.player)) { store in
                    WithViewStore(store, observe: { $0.id }) { playerViewStore in
                        PlayerRow(store: store)
                            .swipeActions(allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewStore.send(.deletePlayer(id: playerViewStore.state), animation: .default)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.plain)
                            }
                    }
                }
            }
        }
    }

    private var header: some View {
        WithViewStore(store) { viewStore in
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
        #if os(iOS)
        .listRowSeparator(.hidden)
        #endif
    }
}

extension Store where State == Standing.State, Action == Standing.Action {
    static var preview: Self {
        Self(initialState: .preview, reducer: Standing())
    }
}

private extension Standing.State {
    static var preview: Self {
        Self(players: (IdentifiedArrayOf<Team.State>.example.first?.players[0]).map { [$0] } ?? [])
    }
}
#endif
