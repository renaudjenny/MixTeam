import ComposableArchitecture
import Foundation

struct Team: ReducerProtocol {
    struct State: Equatable, Identifiable, Hashable {
        let id: UUID
        @BindableState var name: String = ""
        var color: MTColor = .aluminium
        @BindableState var image: MTImage = .unknown
        var players: IdentifiedArrayOf<Player.State> = []
        var isArchived = false

        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case setColor(MTColor)
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .setColor(color):
                state.color = color
                for id in state.players.map(\.id) {
                    state.players[id: id]?.color = color
                }
                return .none
            case .binding:
                return .none
            case .player:
                return .none
            }
        }
        .forEach(\.players, action: /Team.Action.player) {
            Player()
        }
    }
}

extension Team.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case color
        case image
        case playerIDs
        case isArchived
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Team.State.ID.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        color = try values.decode(MTColor.self, forKey: .color)
        image = try values.decode(MTImage.self, forKey: .image)
        let playersIDs = try values.decode([Player.State.ID].self, forKey: .playerIDs)
        players = IdentifiedArrayOf(uniqueElements: playersIDs.map { Player.State(id: $0) })
        isArchived = try values.decode(Bool.self, forKey: .isArchived)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
        try container.encode(image, forKey: .image)
        try container.encode(players.map(\.id), forKey: .playerIDs)
        try container.encode(isArchived, forKey: .isArchived)
    }
}
