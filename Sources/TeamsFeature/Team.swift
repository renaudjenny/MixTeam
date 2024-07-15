import Assets
import ComposableArchitecture
import Foundation
import ImagePicker
import Models
import PersistenceCore
import PlayersFeature

@Reducer
public struct Team {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let id: UUID
        // TODO: should use Shared API
        public var name: String = ""
        public var color: MTColor = .aluminium
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

    @Dependency(\.legacyTeamPersistence) var legacyTeamPersistence

    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .run { [state] _ in try await legacyTeamPersistence.updateOrAppend(state.persisted) }
            case let .moveBackPlayer(id):
                state.players.remove(id: id)
                return .run { [state] _ in try await legacyTeamPersistence.updateOrAppend(state.persisted) }
            case .player:
                return .none
            case let .illustrationPicker(.imageTapped(image)):
                state.image = image
                return .run { [state] _ in try await legacyTeamPersistence.updateOrAppend(state.persisted) }
            }
        }
        .forEach(\.players, action: /Team.Action.player) {
            Player()
        }
    }
}
