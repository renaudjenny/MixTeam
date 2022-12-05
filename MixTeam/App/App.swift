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
            case .load:
                return .task { await .loaded(TaskResult { try await appPersistence.load() }) }
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
                return .fireAndForget { [state] in
                    try await appPersistence.save(state)
                    try await appPersistence.team.save(state.teams)
                }
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
                return .fireAndForget { [state] in
                    try await appPersistence.save(state)
                    try await appPersistence.team.save(state.teams)
                    try await appPersistence.standing.save(state.standing)
                }
            case .dismissNotEnoughTeamsAlert:
                state.notEnoughTeamsAlert = nil
                return .none
            case .standing:
                return .fireAndForget { [state] in
                    try await appPersistence.standing.save(state.standing)
                }
            case let .team(teamID, .player(playerID, .moveBack)):
                guard var player = state.teams[id: teamID]?.players[id: playerID] else { return .none }
                state.teams[id: teamID]?.players.remove(id: playerID)
                player.isStanding = true
                player.color = .aluminium
                state.standing.players.updateOrAppend(player)
                return .fireAndForget { [state] in
                    try await appPersistence.save(state)
                    try await appPersistence.standing.save(state.standing)
                    try await appPersistence.team.save(state.teams)
                }
            case .team:
                return .fireAndForget { [state] in
                    try await appPersistence.team.save(state.teams)
                }
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
                return .fireAndForget { [state] in
                    try await appPersistence.save(state)
                    try await appPersistence.standing.save(state.standing)
                    try await appPersistence.team.save(state.teams)
                }
            case .scores:
                return .fireAndForget { [state] in
                    try await appPersistence.save(state)
                }
            }
        }
        .forEach(\.teams, action: /Action.team(id:action:)) {
            Team()
        }
    }
}

extension App.State: Codable {
    enum CodingKeys: CodingKey {
        case teamIDs
        case _scores
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        standing = Standing.State()
        let teamsIDs = try values.decode([Team.State.ID].self, forKey: .teamIDs)
        teams = IdentifiedArrayOf(uniqueElements: teamsIDs.map { Team.State(id: $0) })
        _scores = try values.decode(Scores.State.self, forKey: ._scores)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(teams.map(\.id), forKey: .teamIDs)
        try container.encode(_scores, forKey: ._scores)
    }
}

private extension App.State {
    var allPlayers: IdentifiedArrayOf<Player.State> {
        IdentifiedArrayOf(uniqueElements: teams.flatMap(\.players) + standing.players)
    }
}
