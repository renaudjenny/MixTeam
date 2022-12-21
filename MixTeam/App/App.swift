import AsyncAlgorithms
import ComposableArchitecture
import SwiftUI

struct App: ReducerProtocol {
    struct State: Equatable {
        var teamRows: IdentifiedArrayOf<TeamRow1.State> = []
        var standing = Standing.State()
        var _scores = Scores.State()

        var notEnoughTeamsAlert: AlertState<Action>?
    }

    enum Action: Equatable {
        case task
        case update(TaskResult<State>)
        case addTeam
        case mixTeam
        case dismissNotEnoughTeamsAlert
        case standing(Standing.Action)
        case teamRow(id: Team.State.ID, action: TeamRow1.Action)
        case deleteTeams(IndexSet)
        case scores(Scores.Action)
    }

    @Dependency(\.appPersistence) var appPersistence
    @Dependency(\.shufflePlayers) var shufflePlayers
    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.standing, action: /Action.standing) {
            Standing()
        }
        Scope(state: \.scores, action: /Action.scores) {
            Scores()
        }
        Reduce { state, action in
            switch action {
            case .task:
                return .task {
                    return await .update(TaskResult { try await appPersistence.load() })
                }
                .animation(.default)
            case let .update(result):
                switch result {
                case let .success(result):
                    state = result
                    return .none
                case let .failure(error):
                    // TODO: do something to show an error screen
                    return .none
                }
            case .addTeam:
                let image = MTImage.teams.randomElement() ?? .koala
                let color = MTColor.allCases.filter({ $0 != .aluminium }).randomElement() ?? .aluminium
                let name = "\(color.rawValue) \(image.rawValue)".localizedCapitalized
                let team = Team.State(id: uuid(), name: name, color: color, image: image)
                state.teamRows.append(TeamRow1.State(id: team.id))
                return .fireAndForget { [state] in
                    try await appPersistence.save(state)
                    try await appPersistence.team.updateOrAppend(team)
                }
            case .mixTeam:
                guard state.teamRows.count > 1 else {
                    state.notEnoughTeamsAlert = .notEnoughTeams
                    return .none
                }
                var teams = IdentifiedArrayOf(uniqueElements: state.teamRows.compactMap { teamRow -> Team.State? in
                    if case let .loaded(team) = teamRow.row { return team } else { return nil }
                })
                let playerIDs = state.standing.playerIDs + teams.flatMap(\.playerIDs)
                guard playerIDs.count > 0 else { return .none }

                teams = IdentifiedArrayOf(uniqueElements: teams.map {
                    var team = $0
                    team.playerIDs = []
                    return team
                })

                teams = shufflePlayers(playerIDs: playerIDs).reduce(teams) { teams, playerID in
                    var teams = teams
                    guard let lessPlayerTeam = teams
                        .sorted(by: { $0.playerIDs.count < $1.playerIDs.count })
                        .first
                    else { return teams }
                    teams[id: lessPlayerTeam.id]?.playerIDs.append(playerID)
                    return teams
                }
                state.standing.playerIDs = []
                return .fireAndForget { [state, teams] in
                    try await appPersistence.team.save(teams)
                    try await appPersistence.save(state)
                }
            case .dismissNotEnoughTeamsAlert:
                state.notEnoughTeamsAlert = nil
                return .none
            case .standing:
                return .none
            case let .teamRow(_,.team(.player(id, .moveBack))):
                state.standing.playerIDs.append(id)
                return .fireAndForget { [state] in
                    try await appPersistence.save(state)
                }
            case .teamRow:
                return .none
            case let .deleteTeams(indexSet):
                var teams = IdentifiedArrayOf(uniqueElements: state.teamRows.compactMap { teamRow -> Team.State? in
                    if case let .loaded(team) = teamRow.row { return team } else { return nil }
                })
                for index in indexSet {
                    state.standing.playerIDs.append(contentsOf: teams[index].playerIDs)
                }
                teams.remove(atOffsets: indexSet)
                state.teamRows.remove(atOffsets: indexSet)
                return .fireAndForget { [state, teams] in
                    try await appPersistence.save(state)
                    try await appPersistence.team.save(teams)
                }
            case .scores:
                return .none
            }
        }
        .forEach(\.teamRows, action: /Action.teamRow) {
            TeamRow1()
        }
//        ._printChanges()
    }
}

extension App.State: Codable {
    enum CodingKeys: CodingKey {
        case teamRows
        case standing
        case _scores
    }
}
