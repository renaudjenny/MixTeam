import Assets
import ComposableArchitecture
import Foundation
import ImagePicker
import Models
import PersistenceCore
import PlayersFeature

public struct Team: ReducerProtocol {

    public typealias Player = PlayersFeature.Player

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
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state.toPersist) }
            case .binding:
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state.toPersist) }
            case let .moveBackPlayer(id):
                state.players.remove(id: id)
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state.toPersist) }
            case .player:
                return .none
            case let .illustrationPicker(.imageTapped(image)):
                state.image = image
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state.toPersist) }
            }
        }
        .forEach(\.players, action: /Team.Action.player) {
            Player()
        }
    }
}

public extension Team.State {
    var toPersist: PersistedTeam {
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
            let teamPlayers = IdentifiedArrayOf(uniqueElements: playerIDs.compactMap { players[id: $0]?.state })
            return TeamsCore.Team.State(
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
        guard let koalaTeamId = UUID(uuidString: "00E9D827-9FAD-4686-83F2-FAD24D2531A2"),
              let purpleElephantId = UUID(uuidString: "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"),
              let blueLionId = UUID(uuidString: "6634515C-19C9-47DF-8B2B-036736F9AEA9")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        let playersExample: IdentifiedArrayOf<PlayersFeature.Player.State> = .example
        let players = IdentifiedArrayOf<PlayersFeature.Player.State>(uniqueElements: playersExample.suffix(1))

        return [
            Team.State(
                id: koalaTeamId,
                name: "Strawberry Koala",
                color: .strawberry,
                image: .koala,
                players: players,
                isArchived: false
            ),
            Team.State(
                id: purpleElephantId,
                name: "Lilac Elephant",
                color: .lilac,
                image: .elephant,
                players: [],
                isArchived: false
            ),
            Team.State(
                id: blueLionId,
                name: "Bluejeans Lion",
                color: .bluejeans,
                image: .lion,
                players: [],
                isArchived: false
            ),
        ]
    }
}
