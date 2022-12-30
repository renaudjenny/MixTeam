import ComposableArchitecture
import Foundation

struct Composition: ReducerProtocol {
    struct State: Equatable {
        var teams: IdentifiedArrayOf<Team.State> = []
        var standing = Standing.State()

        var notEnoughTeamsAlert: AlertState<Action>?
    }

    enum Action: Equatable {
        case addTeam
        case mixTeam
        case dismissNotEnoughTeamsAlert
        case standing(Standing.Action)
        case team(id: Team.State.ID, action: Team.Action)
        case deleteTeams(IndexSet)
    }

    @Dependency(\.appPersistence.saveComposition) var save
    @Dependency(\.appPersistence.team) var teamPersistance
    @Dependency(\.shufflePlayers) var shufflePlayers
    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.standing, action: /Action.standing) {
            Standing()
        }
        Reduce { state, action in
            switch action {
            case .addTeam:
                let image = MTImage.teams.randomElement() ?? .koala
                let color = MTColor.allCases.filter({ $0 != .aluminium }).randomElement() ?? .aluminium
                let name = "\(color.rawValue) \(image.rawValue)".localizedCapitalized
                let team = Team.State(id: uuid(), name: name, color: color, image: image)
                state.teams.append(team)
                return .fireAndForget { [state] in
                    try await save(state)
                    try await teamPersistance.updateOrAppend(team)
                }
            case .mixTeam:
                guard state.teams.count > 1 else {
                    state.notEnoughTeamsAlert = .notEnoughTeams
                    return .none
                }
                let players = state.standing.players + state.teams.flatMap(\.players)
                guard players.count > 0 else { return .none }

                state.teams = IdentifiedArrayOf(uniqueElements: state.teams.map {
                    var team = $0
                    team.players = []
                    return team
                })

                state.teams = IdentifiedArrayOf(
                    uniqueElements: shufflePlayers(players: players.elements).reduce(state.teams) { teams, player in
                        var teams = teams
                        var player = player
                        guard let lessPlayerTeam = teams
                            .sorted(by: { $0.players.count < $1.players.count })
                            .first
                        else { return teams }
                        guard var team = teams[id: lessPlayerTeam.id] else { return teams }
                        player.color = team.color
                        player.isStanding = false
                        team.players.updateOrAppend(player)
                        teams.updateOrAppend(team)
                        return teams
                    }
                )
                state.standing.players = []
                return .fireAndForget { [state] in
                    try await teamPersistance.updateValues(state.teams)
                    try await save(state)
                }
            case .dismissNotEnoughTeamsAlert:
                state.notEnoughTeamsAlert = nil
                return .none
            case .standing:
                return .none
            case let .team(teamID, .player(playerID, .moveBack)):
                guard
                    var team = state.teams[id: teamID],
                    var player = team.players[id: playerID]
                else { return .none }
                team.players.remove(id: player.id)
                player.isStanding = true
                player.color = .aluminium
                state.standing.players.append(player)
                state.teams.updateOrAppend(team)
                return .fireAndForget { [state, team] in
                    try await save(state)
                    try await teamPersistance.updateOrAppend(team)
                }
            case .team:
                return .none
            case let .deleteTeams(indexSet):
                var archivedTeams: IdentifiedArrayOf<Team.State> = []
                for index in indexSet {
                    archivedTeams.append(state.teams[index])
                    let players = state.teams[index].players.map {
                        var player = $0
                        player.isStanding = true
                        player.color = .aluminium
                        return player
                    }
                    state.standing.players.append(contentsOf: players)
                }
                state.teams.remove(atOffsets: indexSet)
                return .fireAndForget { [state, archivedTeams] in
                    try await save(state)
                    let archivedTeams = IdentifiedArrayOf(uniqueElements: archivedTeams.map {
                        var team = $0
                        team.isArchived = true
                        return team
                    })
                    try await teamPersistance.updateValues(archivedTeams)
                }
            }
        }
        .forEach(\.teams, action: /Action.team) {
            Team()
        }
    }
}
