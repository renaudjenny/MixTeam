import ComposableArchitecture
import Foundation

struct Team: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        var name: String = ""
        var colorIdentifier: ColorIdentifier = .gray
        var imageIdentifier: ImageIdentifier = .unknown
        var players: IdentifiedArrayOf<Player> = []
    }
    enum Action: Equatable {
        case nameUpdated(String)
        case colorUpdated(ColorIdentifier)
        case imageUpdated(ImageIdentifier)
        case playerAdded(Player)
        case playerUpdated(Player)
    }

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
        case let .playerAdded(player), let .playerUpdated(player):
            state.players.updateOrAppend(player)
            return .none
        }
    }
}

struct DprTeam: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String = ""
    var colorIdentifier: ColorIdentifier = .gray
    var imageIdentifier: ImageIdentifier = .unknown
    var players: IdentifiedArrayOf<Player> = []
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
