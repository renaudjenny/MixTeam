import ComposableArchitecture
import Foundation

struct Team: ReducerProtocol {
    struct State: Equatable, Identifiable, Codable {
        let id: UUID
        var name: String = ""
        var colorIdentifier: ColorIdentifier = .gray
        var imageIdentifier: ImageIdentifier = .unknown
        var isFirstRow = false
        var players: IdentifiedArrayOf<Player.State> = []
    }

    enum Action: Equatable {
        case nameUpdated(String)
        case colorUpdated(ColorIdentifier)
        case imageUpdated(ImageIdentifier)
        case edit
        case delete
        case createPlayer
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
            return .none
        case let .imageUpdated(image):
            state.imageIdentifier = image
            return .none
        case .edit:
            return .none
        case .delete:
            return .none
        case .createPlayer:
            let name = DprPlayer.placeholders.randomElement() ?? ""
            let image = ImageIdentifier.players.randomElement() ?? .unknown
            let player = Player.State(id: uuid(), name: name, image: image, isInFirstRow: state.isFirstRow)
            state.players.updateOrAppend(player)
            return .none
        case .player:
            return .none
        }
    }
}

struct DprTeam: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String = ""
    var colorIdentifier: ColorIdentifier = .gray
    var imageIdentifier: ImageIdentifier = .unknown
    var players: IdentifiedArrayOf<DprPlayer> = []
}

#if DEBUG
extension DprTeam {
    static var test: Self {
        DprTeam(
            id: UUID(),
            name: "Team Test",
            colorIdentifier: .red,
            imageIdentifier: .koala,
            players: []
        )
    }
}
#endif
