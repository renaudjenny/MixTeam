import ComposableArchitecture
import SwiftUI

struct StandingView: View {
    let store: StoreOf<Standing>

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            Section {
                header
                playersView
            }
            .task { @MainActor in viewStore.send(.load) }
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

    private typealias PlayerAction = (Player.State.ID, Player.Action)
    private typealias PlayersState = IdentifiedArrayOf<Player.State>

    private var playersView: some View {
        SwitchStore(store.scope(state: \.players, action: Standing.Action.player(id:action:))) {
            CaseLet(state: /Standing.Players.loading) { (_: Store<Void, PlayerAction>) in
                loadingView
            }
            CaseLet(state: /Standing.Players.loaded) { (store: Store<PlayersState, PlayerAction>) in
                ForEachStore(store, content: PlayerRow.init)
            }
            CaseLet(state: /Standing.Players.error) { (store: Store<String, PlayerAction>) in
                WithViewStore(store.actionless) { viewStore in
                    Text(viewStore.state)
                }
            }
        }
    }

    private var loadingView: some View {
        WithViewStore(store) { viewStore in
            let playersCount = viewStore.playerIDs.count > 0 ? viewStore.playerIDs.count : 1
            ForEach(0..<playersCount, id: \.self) { _ in
                HStack {
                    Image(mtImage: .unknown)
                        .resizable()
                        .frame(width: 48, height: 48)
                        .redacted(reason: .placeholder)
                    Text("Placeholder name")
                        .fontWeight(.medium)
                        .redacted(reason: .placeholder)
                }
                .backgroundAndForeground(color: .aluminium)
                .padding(.leading, 24)
            }
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
        guard case let .loaded(players) = teams[0].players
        else { fatalError("Cannot load Example first team players") }
        var player = players[0]
        player.isStanding = true
        return Self(playerIDs: [player.id], players: .loaded([player]))

    }
}
#endif
