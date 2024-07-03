import Assets
import ComposableArchitecture
import Foundation
import ImagePicker
import Models
import PersistenceCore

@Reducer
public struct Player {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let id: UUID
        // TODO: name & image should be persisted
        public var name = ""
        public var image: MTImage = .unknown
        public var color: MTColor = .aluminium

        public init(id: UUID, name: String = "", image: MTImage = .unknown, color: MTColor = .aluminium) {
            self.id = id
            self.name = name
            self.image = image
            self.color = color
        }

        var illustrationPicker: IllustrationPicker.State {
            IllustrationPicker.State(
                images: IdentifiedArrayOf(uniqueElements: MTImage.players),
                color: color,
                selectedImage: image
            )
        }
    }

    public enum Action: Equatable {
        case nameChanged(String)
        case illustrationPicker(IllustrationPicker.Action)
    }

    @Dependency(\.playerPersistence) var playerPersistence

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .nameChanged(name):
                state.name = name
                return .run { [state] _ in try await playerPersistence.updateOrAppend(state.persisted) }
            case let .illustrationPicker(.imageTapped(image)):
                state.image = image
                return .run { [state] _ in try await playerPersistence.updateOrAppend(state.persisted) }
            }
        }
    }
}
