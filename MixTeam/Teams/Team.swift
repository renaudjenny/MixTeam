import ComposableArchitecture
import Foundation

struct Team: ReducerProtocol {
    struct State: Equatable, Identifiable, Hashable {
        let id: UUID
        @BindableState var name: String = ""
        var color: MTColor = .aluminium
        @BindableState var image: MTImage = .unknown
        var players: IdentifiedArrayOf<Player.State> = []

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
        case players
    }
}
