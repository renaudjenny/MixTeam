import ComposableArchitecture
import SwiftUI

struct AppData: ReducerProtocol {
    struct State: Equatable {
        var teams: IdentifiedArrayOf<Team.State> = []
        var composition = Composition.State()
        var scores = Scores.State()
        var isLoading = true
        var error: String?
    }

    enum Action: Equatable {
        case task
        case update(TaskResult<State>)
        case composition(Composition.Action)
        case scores(Scores.Action)
    }

    @Dependency(\.appPersistence) var appPersistence
    @Dependency(\.shufflePlayers) var shufflePlayers
    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.composition, action: /Action.composition) {
            Composition()
        }
        Scope(state: \.scores, action: /Action.scores) {
            Scores()
        }
        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                state.error = nil
                return .task {
                    await .update(TaskResult { try await appPersistence.load() })
                }
                .animation(.default)
            case let .update(result):
                state.isLoading = false
                switch result {
                case let .success(result):
                    state.teams = result.teams
                    state.composition = result.composition
                    state.scores = result.scores
                    return .none
                case let .failure(error):
                    state.error = error.localizedDescription
                    return .none
                }
            case .composition(.addTeam):
                state.teams.append(contentsOf: state.composition.teams)
                state.scores.teams.append(contentsOf: state.composition.teams)
                return .fireAndForget { [state] in try await appPersistence.save(state) }
            case let .composition(.team(id, .binding)):
                guard let team = state.composition.teams[id: id] else { return .none }
                state.teams.updateOrAppend(team)
                state.scores.teams.updateOrAppend(team)
                state.scores.rounds = IdentifiedArrayOf(uniqueElements: state.scores.rounds.map {
                    var round = $0
                    round.scores = IdentifiedArrayOf(uniqueElements: round.scores.map {
                        var score = $0
                        if team.id == score.team.id {
                            score.team = team
                        }
                        return score
                    })
                    return round
                })
                return .none
            case .composition(.deleteTeams):
                let deletedTeams = state.teams
                    .filter { !$0.isArchived && !state.composition.teams.contains($0) }
                    .map {
                        var team = $0
                        team.isArchived = true
                        return team
                    }
                for deletedTeam in deletedTeams {
                    state.teams.updateOrAppend(deletedTeam)
                    state.scores.teams.updateOrAppend(deletedTeam)
                }
                return .none
            case .composition:
                return .none
            case .scores:
                return .none
            }
        }
    }
}

struct AppDataView: View {
    let store: StoreOf<AppData>

    struct ViewState: Equatable {
        let isLoading: Bool
        let error: String?

        init(state: AppData.State) {
            isLoading = state.isLoading
            error = state.error
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            NavigationView {
                if viewStore.isLoading {
                    ProgressView("Loading content from saved data")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task { viewStore.send(.task) }
                } else if let error = viewStore.error {
                    errorCardView(description: error)
                } else {
                    CompositionView(store: store.scope(state: \.composition, action: AppData.Action.composition))
                }

            }
            .listStyle(.plain)
            .tabItem {
                Label("Composition", systemImage: "person.2.crop.square.stack")
            }
            .navigationViewStyle(.stack)
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
