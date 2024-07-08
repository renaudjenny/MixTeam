import Assets
import ComposableArchitecture
import PlayersFeature
import SwiftUI
import StyleCore
import TeamsFeature

public struct CompositionView: View {
    let store: StoreOf<Composition>

    public init(store: StoreOf<Composition>) {
        self.store = store
    }

    public var body: some View {
        List {
            Group {
                StandingView(store: store.scope(state: \.standing, action: \.standing))
                mixTeamButton
                ForEachStore(
                    store.scope(state: \.teams, action: \.team),
                    content: TeamRow.init
                )
                .onDelete { store.send(.archiveTeams($0), animation: .default) }
                addTeamButton
            }
            .listRowBackground(Color.clear)
            #if os(iOS)
            .listRowSeparator(.hidden)
            #endif
        }
        .backgroundAndForeground(color: .aluminium)
        .confirmationDialog(store: store.scope(
            state: \.$notEnoughTeamsConfirmationDialog,
            action: \.dismissNotEnoughTeamsAlert
        ))
    }

    private var mixTeamButton: some View {
        Button { store.send(.mixTeam, animation: .easeInOut) } label: {
            Label("Mix Team", systemImage: "shuffle")
        }
        .buttonStyle(.dashed(color: .aluminium))
        .frame(maxWidth: .infinity)
    }

    private var addTeamButton: some View {
        Button { store.send(.addTeam, animation: .easeInOut) } label: {
            Label("Add a new Team", systemImage: "plus")
        }
        .buttonStyle(DashedButtonStyle(color: .aluminium))
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationView {
        CompositionView(
            store: Store(initialState: Composition.State(
                teams: .example,
                standing: .example
            )) { Composition() }
        )
        .navigationTitle("Composition")
        .listStyle(.plain)
    }
}

public extension Standing.State {
    static var example: Self {
        let players = IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Player.State>.example.prefix(2))
        return Self(players: players)
    }
}
