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
        WithViewStore(store.stateless) { viewStore in
            List {
                Group {
                    StandingView(store: store.scope(state: \.standing, action: Composition.Action.standing))
                    mixTeamButton
                    ForEachStore(
                        store.scope(state: \.teams, action: Composition.Action.team),
                        content: TeamRow.init
                    )
                    .onDelete { viewStore.send(.archiveTeams($0), animation: .default) }
                    addTeamButton
                }
                .listRowBackground(Color.clear)
                #if os(iOS)
                .listRowSeparator(.hidden)
                #endif
            }
            .backgroundAndForeground(color: .aluminium)
            .confirmationDialog(
                store.scope(state: \.notEnoughTeamsConfirmationDialog),
                dismiss: .dismissNotEnoughTeamsAlert
            )
        }
    }

    private var mixTeamButton: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.mixTeam, animation: .easeInOut) } label: {
                Label("Mix Team", systemImage: "shuffle")
            }
            .buttonStyle(.dashed(color: .aluminium))
            .frame(maxWidth: .infinity)
        }
    }

    private var addTeamButton: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.addTeam, animation: .easeInOut) } label: {
                Label("Add a new Team", systemImage: "plus")
            }
            .buttonStyle(DashedButtonStyle(color: .aluminium))
            .frame(maxWidth: .infinity)
        }
    }
}

#if DEBUG
struct CompositionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CompositionView(store: .preview)
        }
    }
}

extension Store where State == Composition.State, Action == Composition.Action {
    static var preview: Self {
        Self(initialState: .example, reducer: Composition())
    }
}

public extension Composition.State {
    static var example: Self {
        Self(teams: .example, standing: .example)
    }
}

public extension Standing.State {
    static var example: Self {
        let players = IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Player.State>.example.prefix(2))
        return Self(players: players)
    }
}
#endif
