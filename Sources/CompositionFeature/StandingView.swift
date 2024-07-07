import ComposableArchitecture
import PlayersFeature
import SwiftUI
import TeamsFeature

struct StandingView: View {
    let store: StoreOf<Standing>

    var body: some View {
        Section {
            header
            ForEachStore(store.scope(state: \.players, action: \.player)) { playerStore in
                PlayerRow(store: playerStore)
                    .swipeActions(allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.send(.deletePlayer(id: playerStore.id), animation: .default)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                    }
            }
        }
    }

    private var header: some View {
        VStack {
            Text("Players standing for a team")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button { store.send(.createPlayer, animation: .easeInOut) } label: {
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

#Preview {
    NavigationView {
        List {
            StandingView(store: Store(initialState: Standing.State(
                players: (IdentifiedArrayOf<Team.State>.example.first?.players[0]).map { [$0] } ?? []
            )) { Standing() })
        }
        .listStyle(.plain)
        #if os(iOS)
        .listRowSeparator(.hidden)
        #endif
        .navigationTitle("Composition")
        .backgroundAndForeground(color: .aluminium)
    }
}
