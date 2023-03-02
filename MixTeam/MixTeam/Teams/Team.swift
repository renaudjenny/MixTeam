import Assets
import ComposableArchitecture
import Foundation
import ImagePicker

struct Team: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        @BindingState var name: String = ""
        @BindingState var color: MTColor = .aluminium
        @BindingState var image: MTImage = .unknown
        var players: IdentifiedArrayOf<Player.State> = []
        var isArchived = false
        var imagePicker = ImagePicker.State(
            images: IdentifiedArrayOf(uniqueElements: MTImage.teams),
            color: color,
            selectedImage: image
        )
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case moveBackPlayer(id: Player.State.ID)
        case player(id: Player.State.ID, action: Player.Action)
        case imagePicker(ImagePicker.Action)
    }

    @Dependency(\.teamPersistence) var teamPersistence

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .binding(action) where action.keyPath == \.$color:
                state.players = IdentifiedArrayOf(uniqueElements: state.players.map {
                    var player = $0
                    player.color = state.color
                    return player
                })
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state) }
            case .binding:
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state) }
            case let .moveBackPlayer(id):
                state.players.remove(id: id)
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state) }
            case .player:
                return .none
            case let .imagePicker(.didTapImage(image)):
                state.image = image
            }
        }
        .forEach(\.players, action: /Team.Action.player) {
            Player()
        }
    }
}
