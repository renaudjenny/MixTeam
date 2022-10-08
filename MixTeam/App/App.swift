import ComposableArchitecture

struct App: ReducerProtocol {
    struct State: Equatable {
        @available(*, deprecated, message: "Use teams instead")
        var dprTeams: IdentifiedArrayOf<DprTeam> = []
        var teams: IdentifiedArrayOf<Team.State> = []
        var editedPlayer: DprPlayer?
        var editedTeam: Team.State?
        var notEnoughTeamsAlert: AlertState<Action>?
    }
    enum Action: Equatable {
        case saveTeams
        case loadTeams
        case addTeam
        case finishEditingTeam
        case editPlayer(DprPlayer)
        case finishEditingPlayer
        case updatePlayer(DprPlayer)
        case deletePlayer(DprPlayer)
        case moveBackPlayer(DprPlayer)
        case mixTeam
        case dismissNotEnoughTeamsAlert
        case team(id: Team.State.ID, action: Team.Action)
        case teamEdited(Team.Action)
    }
    @Dependency(\.saveTeams) var saveTeams
    @Dependency(\.loadedTeams) var loadedTeams
    @Dependency(\.uuid) var uuid

    // swiftlint:disable:next cyclomatic_complexity
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .saveTeams:
                saveTeams(state.teams.elements)
                return .none
            case .loadTeams:
                state.teams = IdentifiedArrayOf(uniqueElements: loadedTeams)
                return .none
            case .addTeam:
                let image = ImageIdentifier.teams.randomElement() ?? .koala
                let color = ColorIdentifier.allCases.randomElement() ?? .red
                let name = "\(color.name) \(image.name)".localizedCapitalized
                state.teams.updateOrAppend(
                    Team.State(id: uuid(), name: name, colorIdentifier: color, imageIdentifier: image)
                )
                return Effect(value: .saveTeams)
            case .finishEditingTeam:
                state.editedTeam = nil
                return .none
            case let .editPlayer(player):
                state.editedPlayer = player
                return .none
            case .finishEditingPlayer:
                state.editedPlayer = nil
                return .none
            case let .updatePlayer(player):
                guard var team = state.dprTeams.first(where: { $0.players.contains(player) }) else { return .none }
                team.players.updateOrAppend(player)
                state.dprTeams.updateOrAppend(team)
                return Effect(value: .saveTeams)
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
                guard state.dprTeams.count > 2 else {
                    state.notEnoughTeamsAlert = AlertState(
                        title: TextState("Couldn't Mix Team with less than 2 teams. Go create some teams :)")
                    )
                    return .none
                }

                let players = state.dprTeams.flatMap(\.players)
                guard players.count > 0 else { return .none }

                state.dprTeams = IdentifiedArrayOf(uniqueElements: state.dprTeams.map {
                    var newTeam = $0
                    newTeam.players = []
                    return newTeam
                })

                state.dprTeams = players.shuffled().reduce(state.dprTeams) { teams, player in
                    var teams = teams
                    let availableTeams = teams.filter { $0 != teams.first }
                    guard let lessPlayerTeam = availableTeams
                        .sorted(by: { $0.players.count < $1.players.count  })
                        .first
                    else { return teams }
                    teams[id: lessPlayerTeam.id]?.players.updateOrAppend(player)
                    return teams
                }
                return Effect(value: .saveTeams)
            case .dismissNotEnoughTeamsAlert:
                state.notEnoughTeamsAlert = nil
                return .none
            case let .team(id, .edit):
                state.editedTeam = state.teams[id: id]
                return .none
            case let .team(id, .delete):
                state.teams.remove(id: id)
                return Effect(value: .saveTeams)
            case .team(id:action:):
                return Effect(value: .saveTeams)
            case .teamEdited:
                return .none
            }
        }
        .forEach(\.teams, action: /Action.team(id:action:)) {
            Team()
        }
    }
}
