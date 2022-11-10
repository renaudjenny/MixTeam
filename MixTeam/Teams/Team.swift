import ComposableArchitecture
import Foundation

struct Team: ReducerProtocol {
    struct State: Equatable, Identifiable, Codable, Hashable {
        let id: UUID
        var name: String = ""
        var colorIdentifier: ColorIdentifier = .gray
        var imageIdentifier: ImageIdentifier = .unknown
        var players: IdentifiedArrayOf<Player.State> = []

        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    enum Action: Equatable {
        case nameUpdated(String)
        case colorUpdated(ColorIdentifier)
        case imageUpdated(ImageIdentifier)
        case edit
        case delete
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid

    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case let .nameUpdated(name):
            state.name = name
            return .none
        case let .colorUpdated(color):
            state.colorIdentifier = color
            for playerID in state.players.map(\.id) {
                state.players[id: playerID]?.color = color
            }
            return .none
        case let .imageUpdated(image):
            state.imageIdentifier = image
            return .none
        case .edit:
            return .none
        case .delete:
            return .none
        case .player:
            return .none
        }
    }
}
