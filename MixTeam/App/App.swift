import ComposableArchitecture
import SwiftUI

struct App: ReducerProtocol {
    struct State: Equatable {
        var standing = Standing.State()
        var teams: IdentifiedArrayOf<Team.State> = []
        var _scores = Scores.State()
        var notEnoughTeamsAlert: AlertState<Action>?
    }

    enum Action: Equatable {
        case saveState
        case load
        case loaded(TaskResult<State>)
        case addTeam
        case mixTeam
        case dismissNotEnoughTeamsAlert
        case standing(Standing.Action)
        case team(id: Team.State.ID, action: Team.Action)
        case deleteTeams(IndexSet)
        case scores(Scores.Action)
    }

    @Dependency(\.save) var save
    @Dependency(\.load) var load
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
            case .saveState:
                return .fireAndForget { [state] in
                    try await save(state)
                }
            case .load:
                return .task { await .loaded(TaskResult { try await load() }) }
            case let .loaded(loaded):
                switch loaded {
                case let .success(newState):
                    state = newState
                    return .none
                case .failure:
                    return .none
                }
            case .addTeam:
                let image = MTImage.teams.randomElement() ?? .koala
                let color = MTColor.allCases.filter({ $0 != .aluminium }).randomElement() ?? .aluminium
                let name = "\(color.rawValue) \(image.rawValue)".localizedCapitalized
                state.teams.updateOrAppend(
                    Team.State(id: uuid(), name: name, color: color, image: image)
                )
                return Effect(value: .saveState)
            case .mixTeam:
                guard state.teams.count > 1 else {
                    state.notEnoughTeamsAlert = .notEnoughTeams
                    return .none
                }

                let players: [Player.State] = state.standing.players + state.teams.flatMap(\.players)
                guard players.count > 0 else { return .none }

                state.teams = IdentifiedArrayOf(uniqueElements: state.teams.map {
                    var newTeam = $0
                    newTeam.players = []
                    return newTeam
                })

                state.teams = shufflePlayers(players: players).reduce(state.teams) { teams, player in
                    var teams = teams
                    var player = player
                    guard let lessPlayerTeam = teams
                        .sorted(by: { $0.players.count < $1.players.count  })
                        .first
                    else { return teams }
                    player.isStanding = false
                    player.color = lessPlayerTeam.color
                    teams[id: lessPlayerTeam.id]?.players.updateOrAppend(player)
                    return teams
                }
                state.standing.players = []
                return Effect(value: .saveState)
            case .dismissNotEnoughTeamsAlert:
                state.notEnoughTeamsAlert = nil
                return .none
            case .standing:
                return Effect(value: .saveState)
            case let .team(teamID, .player(playerID, .moveBack)):
                guard var player = state.teams[id: teamID]?.players[id: playerID] else { return .none }
                state.teams[id: teamID]?.players.remove(id: playerID)
                player.isStanding = true
                player.color = .aluminium
                state.standing.players.updateOrAppend(player)
                return Effect(value: .saveState)
            case .team:
                return Effect(value: .saveState)
            case let .deleteTeams(indexSet):
                for index in indexSet {
                    var players = state.teams[index].players
                    players = IdentifiedArrayOf(uniqueElements: players.map {
                        var player = $0
                        player.isStanding = true
                        player.color = .aluminium
                        return player
                    })
                    state.standing.players.append(contentsOf: players)
                }
                state.teams.remove(atOffsets: indexSet)
                return Effect(value: .saveState)
            case .scores:
                return Effect(value: .saveState)
            }
        }
        .forEach(\.teams, action: /Action.team(id:action:)) {
            Team()
        }
    }
}

extension App.State: Codable {
    enum CodingKeys: CodingKey {
        case standing
        case teams
        case _scores
    }
}
