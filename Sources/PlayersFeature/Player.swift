import Assets
import ComposableArchitecture
import Foundation
import ImagePicker
import Models
import PersistenceCore

public struct Player: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public let id: UUID
        @BindingState public var name = ""
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
                return .fireAndForget { [state] in try await playerPersistence.updateOrAppend(state.persisted) }
            case let .illustrationPicker(.imageTapped(image)):
                state.image = image
                return .fireAndForget { [state] in try await playerPersistence.updateOrAppend(state.persisted) }
            }
        }
    }
}

public extension Player.State {
    var persisted: PersistedPlayer {
        PersistedPlayer(id: id, name: name, image: image)
    }
}

public extension PersistedPlayer {
    var state: Player.State {
        Player.State(id: id, name: name, image: image)
    }
}

public extension IdentifiedArrayOf<Player.State> {
    static var example: Self {
        guard let ameliaID = UUID(uuidString: "F336E7F8-78AC-439B-8E32-202DE58CFAC2"),
              let joseID = UUID(uuidString: "C0F0266B-FFF1-47B0-8A2C-CC90BC36CF15"),
              let jackID = UUID(uuidString: "34BC8929-C2F6-42D5-8131-8F048CE649A6")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        return [
            Player.State(id: ameliaID, name: "Amelia", image: .amelie),
            Player.State(id: joseID, name: "José", image: .santa),
            Player.State(id: jackID, name: "Jack", image: .jack),
        ]
    }
}
