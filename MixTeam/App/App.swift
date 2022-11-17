import ComposableArchitecture

struct App: ReducerProtocol {
    struct State: Equatable {
        var standing = Standing.State()
        var teams: IdentifiedArrayOf<Team.State> = []
        var _scores = Scores.State()
        var editedPlayer: Player.State?
        var editedTeamID: Team.State.ID?
        var notEnoughTeamsAlert: AlertState<Action>?

        var isEditTeamSheetPresented: Bool { editedTeamID != nil }
        var isEditPlayerSheetPresented: Bool { editedPlayer != nil }
        var editedTeam: Team.State? { editedTeamID.flatMap { teams[id: $0] } }
    }

    enum Action: Equatable {
        case saveState
        case loadState
        case addTeam
        case setEditTeamSheet(isPresented: Bool)
        case setEditPlayerSheetIsPresented(Bool)
        case finishEditingPlayer
        case mixTeam
        case dismissNotEnoughTeamsAlert
        case standing(Standing.Action)
        case team(id: Team.State.ID, action: Team.Action)
        case editedTeam(Team.Action)
        case playerEdited(Player.Action)
        case scores(Scores.Action)
    }

    @Dependency(\.save) var save
    @Dependency(\.loaded) var loaded
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
                save(state)
                return .none
            case .loadState:
                state = loaded
                return .none
            case .addTeam:
                let image = ImageIdentifier.teams.randomElement() ?? .koala
                let color = ColorIdentifier.allCases.randomElement() ?? .red
                let name = "\(color.name) \(image.name)".localizedCapitalized
                state.teams.updateOrAppend(
                    Team.State(id: uuid(), name: name, colorIdentifier: color, imageIdentifier: image)
                )
                return Effect(value: .saveState)
            case .setEditTeamSheet(isPresented: false):
                state.editedTeamID = nil
                return .none
            case .setEditTeamSheet:
                return .none
            case .setEditPlayerSheetIsPresented(false):
                state.editedPlayer = nil
                return .none
            case .setEditPlayerSheetIsPresented:
                return .none
            case .finishEditingPlayer:
                state.editedPlayer = nil
                return .none
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
                    player.color = lessPlayerTeam.colorIdentifier
                    teams[id: lessPlayerTeam.id]?.players.updateOrAppend(player)
                    return teams
                }
                state.standing.players = []
                return Effect(value: .saveState)
            case .dismissNotEnoughTeamsAlert:
                state.notEnoughTeamsAlert = nil
                return .none
            case let .standing(.player(id, .edit)):
                guard let player = state.standing.players[id: id] else { return .none }
                state.editedPlayer = player
                return .none
            case .standing:
                return Effect(value: .saveState)
            case let .team(teamID, .setEdit(isPresented)):
                state.editedTeamID = isPresented ? teamID : nil
                return .task { .setEditTeamSheet(isPresented: isPresented) }
            case let .team(teamID, .player(playerID, .moveBack)):
                guard var player = state.teams[id: teamID]?.players[id: playerID] else { return .none }
                state.teams[id: teamID]?.players.remove(id: playerID)
                player.isStanding = true
                player.color = .gray
                state.standing.players.updateOrAppend(player)
                return Effect(value: .saveState)
            case let .team(teamID, .player(playerID, .edit)):
                guard let player = state.teams[id: teamID]?.players[id: playerID] else { return .none }
                state.editedPlayer = player
                return .none
            case let .team(teamID, .delete):
                guard var players = state.teams[id: teamID]?.players else { return .none }
                players = IdentifiedArrayOf(uniqueElements: players.map {
                    var player = $0
                    player.isStanding = true
                    player.color = .gray
                    return player
                })
                state.standing.players.append(contentsOf: players)
                state.teams.remove(id: teamID)
                state.editedTeamID = nil
                return Effect(value: .saveState)
            case .team:
                return Effect(value: .saveState)
            case let .editedTeam(teamAction):
                guard let teamID = state.editedTeamID else { return .none }
                return .task { .team(id: teamID, action: teamAction) }
            case .playerEdited:
                guard let editedPlayer = state.editedPlayer else { return .none }
                if let teamID = state.teams.first(where: { $0.players.contains(editedPlayer) })?.id {
                    state.teams[id: teamID]?.players[id: editedPlayer.id] = editedPlayer
                } else if state.standing.players.contains(editedPlayer) {
                    state.standing.players[id: editedPlayer.id] = editedPlayer
                }
                return Effect(value: .saveState)
            case .scores:
                return Effect(value: .saveState)
            }
        }
        .forEach(\.teams, action: /Action.team(id:action:)) {
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
        case _scores
    }
}
