import ComposableArchitecture
import SwiftUI

struct App: ReducerProtocol {
    struct State: Equatable {
        var teams: IdentifiedArrayOf<Team.State> = []
        var composition = Composition.State()
        var scores = Scores.State()
        var settings = Settings.State()

        var status: Status = .loading
        var selectedTab: Tab = .composition
    }

    enum Status: Equatable {
        case loading
        case loaded
        case error(String)
    }

    enum Tab: Equatable {
        case composition
        case scoreboard
        case settings
    }

    enum Action: Equatable {
        case task
        case tabSelected(Tab)
        case update(TaskResult<State>)
        case composition(Composition.Action)
        case scores(Scores.Action)
        case settings(Settings.Action)
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
                state.status = .loading
                return .task {
                    await .update(TaskResult { try await appPersistence.load() })
                }
                .animation(.default)
            case let .update(result):
                switch result {
                case let .success(result):
                    state = result
                    state.status = .loaded
                    return .none
                case let .failure(error):
                    state.status = .error(error.localizedDescription)
                    return .none
                }
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
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
