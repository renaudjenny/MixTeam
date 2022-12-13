import ComposableArchitecture
import SwiftUI

struct StandingView: View {
    let store: StoreOf<Standing>

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            Section {
                header
                SwitchStore(store) {
                    CaseLet(state: /Standing.State.loading, action: Standing.Action.player) { _ in
                        loadingView
                            .task { @MainActor in viewStore.send(.load) }
                    }
                    CaseLet(state: /Standing.State.loaded, action: Standing.Action.player) { loadedStore in
                        ForEachStore(loadedStore, content: PlayerRow.init)
                    }
                    CaseLet(state: /Standing.State.error, action: Standing.Action.player) { error in
                        WithViewStore(error.actionless) { viewStore in
                            Text(viewStore.state)
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

    private var loadingView: some View {
        ForEach(0..<3) { _ in
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
        .loaded(
            players: [Player.State(id: UUID(), name: "Player 1", image: .amelie, color: .aluminium, isStanding: true)]
        )
    }
}
#endif
