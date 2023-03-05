import Assets
import ComposableArchitecture
import Foundation
import ImagePicker
import PersistenceCore

public struct Player: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public let id: UUID
        @BindingState public var name = ""
        public var image: MTImage = .unknown
        public var color: MTColor = .aluminium

        var illustrationPicker: IllustrationPicker.State {
            IllustrationPicker.State(
                images: IdentifiedArrayOf(uniqueElements: MTImage.players),
                color: color,
                selectedImage: image
            )
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case illustrationPicker(IllustrationPicker.Action)
    }

    @Dependency(\.playerPersistence) var playerPersistence

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .fireAndForget { [state] in try await playerPersistence.updateOrAppend(state.toPersist) }
            case let .illustrationPicker(.imageTapped(image)):
                state.image = image
                return .fireAndForget { [state] in try await playerPersistence.updateOrAppend(state.toPersist) }
            }
        }
    }
}

extension Player.State {
    var toPersist: PersistenceCore.Player {
        PersistenceCore.Player(id: id, name: name, image: image)
    }
}
