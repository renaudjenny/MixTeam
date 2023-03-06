import Assets
import ComposableArchitecture
import Foundation
import ImagePicker
import PersistenceCore
import PlayersCore

public struct Team: ReducerProtocol {

    public typealias Player = PlayersCore.Player

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
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case moveBackPlayer(id: Player.State.ID)
        case player(id: Player.State.ID, action: Player.Action)
        case illustrationPicker(IllustrationPicker.Action)
    }

    @Dependency(\.teamPersistence) var teamPersistence

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

extension Team.State {
    var toPersist: PersistenceCore.Team {
        PersistenceCore.Team(
            id: id,
            name: name,
            color: color,
            image: image,
            playerIDs: players.map(\.id),
            isArchived: isArchived
        )
    }
}

extension PersistenceCore.Team {
    var state: TeamsCore.Team.State {
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
