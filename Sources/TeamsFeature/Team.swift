import Assets
import ComposableArchitecture
import Foundation
import ImagePicker
import Models
import PersistenceCore
import PlayersFeature

public struct Team: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public let id: UUID
        @BindingState public var name: String = ""
        @BindingState public var color: MTColor = .aluminium
        public var image: MTImage = .unknown
        public var players: IdentifiedArrayOf<Player.State> = []
        public var isArchived = false
        var illustrationPicker: IllustrationPicker.State {
            IllustrationPicker.State(
                images: IdentifiedArrayOf(uniqueElements: MTImage.teams),
                color: color,
                selectedImage: image
            )
        }

        public init(
            id: UUID,
            name: String,
            color: MTColor,
            image: MTImage,
            players: IdentifiedArrayOf<Player.State> = [],
            isArchived: Bool = false
        ) {
            self.id = id
            self.name = name
            self.color = color
            self.image = image
            self.players = players
            self.isArchived = isArchived
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case moveBackPlayer(id: Player.State.ID)
        case player(id: Player.State.ID, action: Player.Action)
        case illustrationPicker(IllustrationPicker.Action)
    }

    @Dependency(\.teamPersistence) var teamPersistence

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .binding(action) where action.keyPath == \.$color:
                state.players = IdentifiedArrayOf(uniqueElements: state.players.map {
                    var player = $0
                    player.color = state.color
                    return player
                })
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state.persisted) }
            case .binding:
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state.persisted) }
            case let .moveBackPlayer(id):
                state.players.remove(id: id)
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state.persisted) }
            case .player:
                return .none
            case let .illustrationPicker(.imageTapped(image)):
                state.image = image
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state.persisted) }
            }
        }
        .forEach(\.players, action: /Team.Action.player) {
            Player()
        }
    }
}

public extension Team.State {
    var persisted: PersistedTeam {
        PersistedTeam(
            id: id,
            name: name,
            color: color,
            image: image,
            playerIDs: players.map(\.id),
            isArchived: isArchived
        )
    }
}

public extension PersistedTeam {
    var state: Team.State {
        get async throws {
            @Dependency(\.playerPersistence) var playerPersistence

            let players = try await playerPersistence.load()
            let teamPlayers = IdentifiedArrayOf(uniqueElements: playerIDs.compactMap {
                var player = players[id: $0]?.state
                player?.color = color
                return player
            })
            return Team.State(
                id: id,
                name: name,
                color: color,
                image: image,
                players: teamPlayers,
                isArchived: isArchived
            )
        }
    }
}

public extension IdentifiedArrayOf<PersistedTeam> {
    var states: IdentifiedArrayOf<Team.State> {
        get async throws {
            var states: [Team.State] = []
            for team in self {
                states.append(try await team.state)
            }
            return IdentifiedArrayOf<Team.State>(uniqueElements: states)
        }
    }
}

public extension IdentifiedArrayOf<Team.State> {
    static var example: Self {
        let players = IdentifiedArrayOf<Player.State>.example
        var teams: Self = []

        for team in IdentifiedArrayOf<PersistedTeam>.example {
            var playerStates: IdentifiedArrayOf<Player.State> = []
            for playerID in team.playerIDs {
                if let playerState = players[id: playerID] {
                    playerStates.updateOrAppend(playerState)
                }
            }
            teams.updateOrAppend(Team.State(
                id: team.id,
                name: team.name,
                color: team.color,
                image: team.image,
                players: playerStates,
                isArchived: team.isArchived
            ))
        }
        return teams
    }
}
