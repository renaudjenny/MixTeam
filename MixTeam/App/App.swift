import ComposableArchitecture

struct App: ReducerProtocol {
    struct State: Equatable {
        var standing = Standing.State()
        var teams: IdentifiedArrayOf<Team.State> = []
        var _scores = Scores.State()
        var editedPlayerID: Player.State.ID?
        var editedTeamID: Team.State.ID?
        var notEnoughTeamsAlert: AlertState<Action>?

        var isEditTeamSheetPresented: Bool { editedTeamID != nil }
        var isEditPlayerSheetPresented: Bool { editedPlayerID != nil }
        var editedTeam: Team.State? { editedTeamID.flatMap { teams[id: $0] } }
        var editedPlayer: Player.State? {
            editedPlayerID.flatMap { playerID -> Player.State? in
                if let teamID = teams.first(where: { $0.players.map(\.id).contains(playerID) })?.id {
                    return teams[id: teamID]?.players[id: playerID]
                } else if standing.players.map(\.id).contains(playerID) {
                    return standing.players[id: playerID]
                }
                return nil
            }
        }
    }

    enum Action: Equatable {
        case saveState
        case loadState
        case addTeam
        case setEditTeamSheet(isPresented: Bool)
        case setEditPlayerSheet(isPresented: Bool)
        case mixTeam
        case dismissNotEnoughTeamsAlert
        case standing(Standing.Action)
        case team(id: Team.State.ID, action: Team.Action)
        case editedTeam(Team.Action)
        case editedPlayer(Player.Action)
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
            case .setEditPlayerSheet(isPresented: false):
                state.editedPlayerID = nil
                return .none
            case .setEditPlayerSheet:
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
            case let .standing(.player(playerID, .setEdit(isPresented))):
                state.editedPlayerID = isPresented ? playerID : nil
                return .task { .setEditPlayerSheet(isPresented: isPresented) }
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
            case let .team(_, .player(playerID, .setEdit(isPresented))):
                state.editedPlayerID = isPresented ? playerID : nil
                return .task { .setEditPlayerSheet(isPresented: isPresented) }
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
            case let .editedPlayer(playerAction):
                guard let playerID = state.editedPlayerID else { return .none }
                if let teamID = state.teams.first(where: { $0.players.map(\.id).contains(playerID) })?.id {
                    return .task { .team(id: teamID, action: .player(id: playerID, action: playerAction)) }
                } else if state.standing.players.map(\.id).contains(playerID) {
                    return .task { .standing(.player(id: playerID, action: playerAction)) }
                }
                return .none
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
