import ComposableArchitecture
import Foundation

struct Team: ReducerProtocol {
    struct State: Equatable, Identifiable, Hashable {
        let id: UUID
        var name: String = ""
        var colorIdentifier: ColorIdentifier = .gray
        var imageIdentifier: ImageIdentifier = .unknown
        var players: IdentifiedArrayOf<Player.State> = []

        var deleteConfirmationDialog: ConfirmationDialogState<Action>?
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    enum Action: Equatable {
        case nameUpdated(String)
        case colorUpdated(ColorIdentifier)
        case imageUpdated(ImageIdentifier)
        case setEdit(isPresented: Bool)
        case removeTapped
        case removeConfirmationDismissed
        case delete
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
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
            case .setEdit:
                return .none
            case .removeTapped:
                state.deleteConfirmationDialog = .teamDelete
                return .none
            case .removeConfirmationDismissed:
                state.deleteConfirmationDialog = nil
                return .none
            case .delete:
                state.deleteConfirmationDialog = nil
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
        case colorIdentifier
        case imageIdentifier
        case players
    }
}
