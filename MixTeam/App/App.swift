import AsyncAlgorithms
import ComposableArchitecture
import SwiftUI

struct App: ReducerProtocol {
    struct State: Equatable {
        var standing: Standing.State = .loading
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

    private enum LoadTaskID {}
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
                return .run { send in
                    await send(.loaded(
                        TaskResult { try await appPersistence.load() }
                    ))
                }
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
                guard state.teams.count > 1, case let .loaded(standingPlayers) = state.standing else {
                    state.notEnoughTeamsAlert = .notEnoughTeams
                    return .none
                }
                let teamsPlayers = state.teams.flatMap { team -> IdentifiedArrayOf<Player.State> in
                    guard case let .loaded(players) = team.players else { return [] }
                    return players
                }

                let players: [Player.State] = standingPlayers + teamsPlayers
                guard players.count > 0 else { return .none }

                state.teams = IdentifiedArrayOf(uniqueElements: state.teams.map {
                    var newTeam = $0
                    newTeam.players = .loaded([])
                    return newTeam
                })

                state.teams = shufflePlayers(players: players).reduce(state.teams) { teams, player in
                    var teams = teams
                    var player = player
                    guard let lessPlayerTeam = teams
                        .sorted(by: { $0.playerIDs.count < $1.playerIDs.count })
                        .first
                    else { return teams }
                    player.isStanding = false
                    player.color = lessPlayerTeam.color
                    guard case var .loaded(players) = teams[id: lessPlayerTeam.id]?.players else { return teams }
                    players.updateOrAppend(player)
                    teams[id: lessPlayerTeam.id]?.players = .loaded(players)
                    return teams
                }
                state.standing = .loaded(players: [])
                return .fireAndForget { [state] in
                    try await appPersistence.save(state)
                    try await appPersistence.team.save(state.teams)
                    try await appPersistence.standing.save(Standing.Persistence(playerIDs: []))
                }
            case .dismissNotEnoughTeamsAlert:
                state.notEnoughTeamsAlert = nil
                return .none
            case .standing:
                return .none
            case let .team(teamID, .player(playerID, .moveBack)):
                guard
                    case var .loaded(players) = state.teams[id: teamID]?.players,
                    var player = players[id: playerID],
                    case var .loaded(standingPlayers) = state.standing
                else { return .none }
                players.remove(id: playerID)
                state.teams[id: teamID]?.players = .loaded(players)
                player.isStanding = true
                player.color = .aluminium
                standingPlayers.updateOrAppend(player)
                state.standing = .loaded(players: standingPlayers)
                return .fireAndForget { [state, standingPlayers] in
                    try await appPersistence.save(state)
                    try await appPersistence.standing.save(Standing.Persistence(playerIDs: standingPlayers.map(\.id)))
                    try await appPersistence.team.save(state.teams)
                }
            case .team:
                return .none
            case let .deleteTeams(indexSet):
                guard case var .loaded(standingPlayers) = state.standing else { return .none }
                for index in indexSet {
                    guard case var .loaded(players) = state.teams[index].players else { continue }
                    players = IdentifiedArrayOf(uniqueElements: players.map {
                        var player = $0
                        player.isStanding = true
                        player.color = .aluminium
                        return player
                    })
                    standingPlayers.append(contentsOf: players)
                    state.standing = .loaded(players: standingPlayers)
                }
                state.teams.remove(atOffsets: indexSet)
                return .fireAndForget { [state, standingPlayers] in
                    try await appPersistence.save(state)
                    try await appPersistence.standing.save(Standing.Persistence(playerIDs: standingPlayers.map(\.id)))
                    try await appPersistence.team.save(state.teams)
                }
            case .scores:
                return .none
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
        standing = .loading
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
