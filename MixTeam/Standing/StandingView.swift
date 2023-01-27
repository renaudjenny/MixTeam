import ComposableArchitecture
import SwiftUI

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
        let teams: IdentifiedArrayOf<Team.State> = .example
        guard var player = teams.first?.players[0]
        else { fatalError("Cannot load Example first team players") }
        return Self(players: [player])

    }
}
#endif
