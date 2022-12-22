import ComposableArchitecture
import SwiftUI

struct TeamRow: View {
    let store: StoreOf<Team>

    var body: some View {
        Section {
            header
            ForEachStore(store.scope(state: \.players, action: Team.Action.player), content: PlayerRow.init)
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

    private typealias TeamAction = (Team.State.ID, Team.Action)
    private typealias TeamsState = IdentifiedArrayOf<Team.State>

    private struct Preview: View {
        let store: StoreOf<App>

        var body: some View {
            WithViewStore(store) { viewStore in
                NavigationView {
                    List {
                        ForEachStore(store.scope(state: \.teams, action: App.Action.team), content: TeamRow.init)
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
            players: [
                Player.State(id: UUID(), name: "Player 1", image: .amelie, color: .bluejeans),
                Player.State(id: UUID(), name: "Player 2", image: .santa, color: .bluejeans),
            ]
        )
    }
}
#endif
