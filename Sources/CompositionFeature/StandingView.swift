import ComposableArchitecture
import PlayersFeature
import SwiftUI
import TeamsFeature

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
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        NavigationView {
            List {
                StandingView(store: .preview)
            }
            .listStyle(.plain)
            #if os(iOS)
            .listRowSeparator(.hidden)
            #endif
            .navigationTitle("Composition")
            .backgroundAndForeground(color: .aluminium)
        }
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
