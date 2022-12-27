import ComposableArchitecture
import SwiftUI

struct CompositionView: View {
    let store: StoreOf<Composition>

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            List {
                Group {
                    StandingView(store: store.scope(state: \.standing, action: Composition.Action.standing))
                    mixTeamButton
                    ForEachStore(store.scope(state: \.teams, action: Composition.Action.team), content: TeamRow.init)
                        .onDelete { viewStore.send(.deleteTeams($0), animation: .default) }
                    addTeamButton
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
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
