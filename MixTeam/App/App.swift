import ComposableArchitecture

struct App: ReducerProtocol {
    struct State: Equatable {
        @available(*, deprecated, message: "Use teams instead")
        var dprTeams: IdentifiedArrayOf<DprTeam> = []
        var standing = Standing.State()
        var teams: IdentifiedArrayOf<Team.State> = []
        var editedPlayer: Player.State?
        var editedTeam: Team.State?
        var notEnoughTeamsAlert: AlertState<Action>?

        var isEditTeamSheetPresented: Bool { editedTeam != nil }
        var isEditPlayerSheetPresented: Bool { editedPlayer != nil }
    }
    enum Action: Equatable {
        case saveTeams
        case loadTeams
        case addTeam
        case setEditTeamSheetIsPresented(Bool)
        case setEditPlayerSheetIsPresented(Bool)
        case finishEditingPlayer
        case deletePlayer(DprPlayer)
        case moveBackPlayer(DprPlayer)
        case mixTeam
        case dismissNotEnoughTeamsAlert
        case standing(Standing.Action)
        case team(id: Team.State.ID, action: Team.Action)
        case teamEdited(Team.Action)
        case playerEdited(Player.Action)
    }
    @Dependency(\.save) var save
    @Dependency(\.loaded) var loaded
    @Dependency(\.shufflePlayers) var shufflePlayers
    @Dependency(\.uuid) var uuid

    // swiftlint:disable:next cyclomatic_complexity
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.standing, action: /Action.standing) {
            Standing()
        }
        Reduce { state, action in
            switch action {
            case .saveTeams:
                save(state)
                return .none
            case .loadTeams:
                state = loaded
                return .none
            case .addTeam:
                let image = ImageIdentifier.teams.randomElement() ?? .koala
                let color = ColorIdentifier.allCases.randomElement() ?? .red
                let name = "\(color.name) \(image.name)".localizedCapitalized
                state.teams.updateOrAppend(
                    Team.State(id: uuid(), name: name, colorIdentifier: color, imageIdentifier: image)
                )
                return Effect(value: .saveTeams)
            case .setEditTeamSheetIsPresented(false):
                state.editedTeam = nil
                return .none
            case .setEditTeamSheetIsPresented:
                return .none
            case .setEditPlayerSheetIsPresented(false):
                state.editedPlayer = nil
                return .none
            case .setEditPlayerSheetIsPresented:
                return .none
            case .finishEditingPlayer:
                state.editedPlayer = nil
                return .none
            case let .deletePlayer(player):
                guard var team = state.dprTeams.first(where: { $0.players.contains(player) }) else { return .none }
                team.players.remove(player)
                state.dprTeams.updateOrAppend(team)
                return Effect(value: .saveTeams)
            case let .moveBackPlayer(player):
                guard var team = state.dprTeams.first(where: { $0.players.contains(player) }) else { return .none }
                team.players.remove(player)
                state.dprTeams.updateOrAppend(team)

                let firstTeamID = state.dprTeams[0].id
                state.dprTeams[id: firstTeamID]?.players.updateOrAppend(player)
                return Effect(value: .saveTeams)
            case .mixTeam:
                guard state.teams.count > 1 else {
                    state.notEnoughTeamsAlert = .notEnoughTeams
                    return .none
                }

                let players = state.standing.players + state.teams.flatMap(\.players)
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
                    teams[id: lessPlayerTeam.id]?.players.updateOrAppend(player)
                    return teams
                }
                state.standing.players = []
                return Effect(value: .saveTeams)
            case .dismissNotEnoughTeamsAlert:
                state.notEnoughTeamsAlert = nil
                return .none
            case .standing:
                return Effect(value: .saveTeams)
            case let .team(id, .edit):
                state.editedTeam = state.teams[id: id]
                return .none
            case let .team(id, .delete):
                guard var players = state.teams[id: id]?.players else { return .none }
                players = IdentifiedArrayOf(uniqueElements: players.map {
                    var player = $0
                    player.isStanding = true
                    return player
                })
                state.standing.players.append(contentsOf: players)
                state.teams.remove(id: id)
                return Effect(value: .saveTeams)
            case let .team(teamID, .player(playerID, .moveBack)):
                guard var player = state.teams[id: teamID]?.players[id: playerID] else { return .none }
                state.teams[id: teamID]?.players.remove(id: playerID)
                player.isStanding = true
                state.standing.players.updateOrAppend(player)
                return Effect(value: .saveTeams)
            case .team:
                return Effect(value: .saveTeams)
            case .teamEdited:
                guard let editedTeam = state.editedTeam else { return .none }
                state.teams.updateOrAppend(editedTeam)
                return Effect(value: .saveTeams)
            case .playerEdited:
                guard let editedPlayer = state.editedPlayer,
                      var team = state.teams.first(where: { $0.players.contains(editedPlayer) })
                else { return .none }
                team.players.updateOrAppend(editedPlayer)
                state.teams.updateOrAppend(team)
                return Effect(value: .saveTeams)
            }
        }
        .forEach(\.teams, action: /Action.team(id:action:)) {
            Team()
        }
        .ifLet(\.editedTeam, action: /Action.teamEdited) {
            Team()
        }
        .ifLet(\.editedPlayer, action: /Action.playerEdited) {
            Player()
        }
    }
}

extension App.State: Codable {
    enum CodingKeys: CodingKey {
        case standing
        case teams
    }
}
