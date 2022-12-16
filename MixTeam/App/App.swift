import AsyncAlgorithms
import ComposableArchitecture
import SwiftUI

struct App: ReducerProtocol {
    struct State: Equatable {
        var teamIDs: [Team.State.ID] = []
        var _scores = Scores.State()

        var standing = Standing.State(playerIDs: [])
        var teams: Teams = .loading {
            didSet {
                guard case let .loaded(teams) = teams else { return }
                teamIDs = teams.map(\.id)
            }
        }
        var notEnoughTeamsAlert: AlertState<Action>?
    }

    enum Teams: Equatable {
        case loading
        case loaded(IdentifiedArrayOf<Team.State>)
        case error(String)
    }

    struct LoadResult: Equatable {
        let state: State
        let teams: IdentifiedArrayOf<Team.State>
    }

    enum Action: Equatable {
        case load
        case loaded(TaskResult<LoadResult>)
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
                return .task {
                    await .loaded(TaskResult {
                        let state = try await appPersistence.load()
                        let teams = try await appPersistence.team.load().filter { state.teamIDs.contains($0.id) }
                        return LoadResult(state: state, teams: teams)
                    })
                }
            case let .loaded(result):
                switch result {
                case let .success(result):
                    state = result.state
                    state.teams = .loaded(result.teams)
                    return .none
                case let .failure(error):
                    state.teams = .error(error.localizedDescription)
                    return .none
                }
            case .addTeam:
                guard case var .loaded(teams) = state.teams else { return .none }
                let image = MTImage.teams.randomElement() ?? .koala
                let color = MTColor.allCases.filter({ $0 != .aluminium }).randomElement() ?? .aluminium
                let name = "\(color.rawValue) \(image.rawValue)".localizedCapitalized
                teams.updateOrAppend(
                    Team.State(id: uuid(), name: name, color: color, image: image)
                )
                state.teams = .loaded(teams)
                return .fireAndForget { [state, teams] in
                    try await appPersistence.save(state)
                    try await appPersistence.team.save(teams)
                }
            case .mixTeam:
                guard state.teamIDs.count > 1,
                      case let .loaded(standingPlayers) = state.standing.players,
                      case var .loaded(teams) = state.teams
                else {
                    state.notEnoughTeamsAlert = .notEnoughTeams
                    return .none
                }
                let teamsPlayers = teams.flatMap { team -> IdentifiedArrayOf<Player.State> in
                    guard case let .loaded(players) = team.players else { return [] }
                    return players
                }

                let players: [Player.State] = standingPlayers + teamsPlayers
                guard players.count > 0 else { return .none }

                teams = IdentifiedArrayOf(uniqueElements: teams.map {
                    var team = $0
                    team.players = .loaded([])
                    return team
                })

                teams = shufflePlayers(players: players).reduce(teams) { teams, player in
                    var teams = teams
                    var player = player
                    guard let lessPlayerTeam = teams
                        .sorted(by: { $0.playerIDs.count < $1.playerIDs.count })
                        .first
                    else { return teams }
                    player.isStanding = false
                    player.color = lessPlayerTeam.color
                    if case var .loaded(players) = teams[id: lessPlayerTeam.id]?.players {
                        players.updateOrAppend(player)
                        teams[id: lessPlayerTeam.id]?.players = .loaded(players)
                    } else {
                        teams[id: lessPlayerTeam.id]?.players = .loaded([player])
                    }
                    return teams
                }
                state.teams = .loaded(teams)
                state.standing.players = .loaded([])
                return .fireAndForget { [state, teams] in
                    try await appPersistence.save(state)
                    try await appPersistence.team.save(teams)
                    try await appPersistence.standing.save(state.standing)
                }
            case .dismissNotEnoughTeamsAlert:
                state.notEnoughTeamsAlert = nil
                return .none
            case .standing:
                return .none

                // TODO: check if it's well managed by the Player reduced itself
//            case let .team(teamID, .player(playerID, .moveBack)):
//                guard
//                    case var .loaded(teams) = state.teams,
//                    case var .loaded(players) = teams[id: teamID]?.players,
//                    var player = players[id: playerID],
//                    case var .loaded(standingPlayers) = state.standing
//                else { return .none }
//                players.remove(id: playerID)
//                teams[id: teamID]?.players = .loaded(players)
//                state.teams = .loaded(teams)
//                player.isStanding = true
//                player.color = .aluminium
//                standingPlayers.updateOrAppend(player)
//                state.standing = .loaded(players: standingPlayers)
//                return .fireAndForget { [state, standingPlayers, teams] in
//                    try await appPersistence.save(state)
//                    try await appPersistence.standing.save(Standing.Persistence(playerIDs: standingPlayers.map(\.id)))
//                    try await appPersistence.team.save(teams)
//                }
            case .team:
                return .none
            case let .deleteTeams(indexSet):
                guard case var .loaded(standingPlayers) = state.standing.players,
                      case var .loaded(teams) = state.teams
                else { return .none }
                for index in indexSet {
                    guard case var .loaded(players) = teams[index].players else { continue }
                    players = IdentifiedArrayOf(uniqueElements: players.map {
                        var player = $0
                        player.isStanding = true
                        player.color = .aluminium
                        return player
                    })
                    standingPlayers.append(contentsOf: players)
                    state.standing.players = .loaded(standingPlayers)
                }
                teams.remove(atOffsets: indexSet)
                state.teams = .loaded(teams)
                return .fireAndForget { [state, standingPlayers, teams] in
                    try await appPersistence.save(state)
                    try await appPersistence.standing.save(state.standing)
                    try await appPersistence.team.save(teams)
                }
            case .scores:
                return .none
            }
        }
        Scope(state: \.teams, action: /Action.team) {
            EmptyReducer()
                .ifCaseLet(/Teams.loaded, action: /.self) {
                    EmptyReducer()
                        .forEach(\.self, action: /.self) {
                            Team()
                        }
                }
        }
    }
}

extension App.State: Codable {
    enum CodingKeys: CodingKey {
        case teamIDs
        case _scores
    }
}
