import ComposableArchitecture
import SwiftUI

struct TeamRow: View {
    let store: StoreOf<Team>

    var body: some View {
        Section {
            header
            playersView
        }
    }

    private var header: some View {
        WithViewStore(store) { viewStore in
            NavigationLink(destination: EditTeamView(store: store)) {
                HStack {
                    Image(mtImage: viewStore.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                    Text(viewStore.name)
                        .font(.title2)
                        .fontWeight(.black)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                }
            }
            .dashedCardStyle(color: viewStore.color)
            .backgroundAndForeground(color: viewStore.color)
        }
    }

    private var playersView: some View {
        WithViewStore(store.stateless) { viewStore in
            SwitchStore(store.scope(state: \.players, action: Team.Action.player)) {
                CaseLet(state: /Team.Players.loading, action: Team.Action.player) { _ in
                    loadingView
                        .task { @MainActor in viewStore.send(.load) }
                }
                CaseLet(state: /Team.Players.loaded, action: Team.Action.player) { loadedStore in
                    ForEachStore(loadedStore, content: PlayerRow.init)
                }
                CaseLet(state: /Team.Players.error, action: Team.Action.player) { _ in
//                    WithViewStore(error.actionless) { viewStore in
                        // TODO: display correct error
                        Text("TODO error")
//                    }
                }
            }
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
struct TeamRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                TeamRow(store: .preview)
            }
            .listStyle(.plain)
            .padding()
        }
        .previewDisplayName("Team Row Without Players")

        NavigationView {
            List {
                TeamRow(store: .previewWithPlayers)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .padding()
        }
        .previewDisplayName("Team Row With Players")
    }
}

struct TeamRowUX_Previews: PreviewProvider {
    static var previews: some View {
        Preview(store: .preview)
    }

    private struct Preview: View {
        let store: StoreOf<App>

        var body: some View {
            WithViewStore(store) { viewStore in
                NavigationView {
                    List {
                        ForEachStore(store.scope(state: \.teams, action: App.Action.team), content: TeamRow.init)
                            .listRowSeparator(.hidden)
                        Button { viewStore.send(.addTeam, animation: .easeInOut) } label: {
                            Text("Add Team")
                        }
                    }
                }
            }
        }
    }
}

extension Store where State == Team.State, Action == Team.Action {
    static var preview: Self {
        Self(initialState: .preview, reducer: Team())
    }
    static var previewWithPlayers: Self {
        Self(initialState: .previewWithPlayers, reducer: Team())
    }
}

extension Team.State {
    static var preview: Self {
        guard let id = UUID(uuidString: "EF9D6B84-B19A-4177-B5F7-6E2478FAAA18") else {
            fatalError("Cannot generate UUID from a defined UUID String")
        }
        return Team.State(
            id: id,
            name: "Team test",
            color: MTColor.allCases.filter({ $0 != .aluminium}).randomElement() ?? .aluminium,
            image: MTImage.teams.randomElement() ?? .koala
        )
    }

    static var previewWithPlayers: Self {
        guard let id = UUID(uuidString: "EF9D6B84-B19A-4177-B5F7-6E2478FAAA18") else {
            fatalError("Cannot generate UUID from a defined UUID String")
        }
        return Self(
            id: id,
            name: "Team test",
            color: .bluejeans,
            image: .octopus,
            players: .loaded([
                Player.State(id: UUID(), name: "Player 1", image: .amelie, color: .bluejeans),
                Player.State(id: UUID(), name: "Player 2", image: .santa, color: .bluejeans),
            ])
        )
    }
}
#endif
