import ComposableArchitecture
import SwiftUI

struct Archives: ReducerProtocol {
    struct State: Equatable {
        var teams: IdentifiedArrayOf<Team.State> = []
        var players: IdentifiedArrayOf<Player.State> = []
        var isLoading = true
        var error: String?
    }

    enum Action: Equatable {
        case task
        case update(TaskResult<State>)
    }

    @Dependency(\.appPersistence.team) var teamPersistence
    @Dependency(\.appPersistence.player) var playerPersistence

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            state.isLoading = true
            state.error = nil
            return .task {
                await .update(TaskResult {
                    async let teams = teamPersistence.load()
                    async let players = playerPersistence.load()
                    return try await State(teams: teams, players: players)
                })
            }
        case let .update(result):
            state.isLoading = false
            switch result {
            case let .success(result):
                state.teams = result.teams
                state.players = result.players
                return .none
            case let .failure(error):
                state.error = error.localizedDescription
                return .none
            }
        }
    }
}

struct ArchivesView: View {
    let store: StoreOf<Archives>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.isLoading {
                ProgressView("Loading content from saved data")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task { viewStore.send(.task) }
            } else if let error = viewStore.error {
                errorCardView(description: error)
            } else {
                List {
                    Section("Teams") {
                        ForEach(viewStore.teams.filter(\.isArchived)) { team in
                            Text(team.name)
                        }
                    }
                    Section("Players") {
                        ForEach(viewStore.players.filter(\.isArchived)) { player in
                            Text(player.name)
                        }
                    }
                }
            }
        }
    }

    private func errorCardView(description: String) -> some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(description)
                Button { viewStore.send(.task, animation: .default) } label: {
                    Text("Retry")
                }
                .buttonStyle(.dashed(color: MTColor.strawberry))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundAndForeground(color: .strawberry)
        }
    }
}
