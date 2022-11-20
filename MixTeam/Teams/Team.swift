import ComposableArchitecture
import Foundation

struct Team: ReducerProtocol {
    struct State: Equatable, Identifiable, Hashable {
        let id: UUID
        @BindableState var name: String = ""

        @available(*, deprecated)
        var colorIdentifier: ColorIdentifier = .gray

        var color: MTColor = .aluminium

        @BindableState var imageIdentifier: ImageIdentifier = .unknown
        var players: IdentifiedArrayOf<Player.State> = []

        var deleteConfirmationDialog: ConfirmationDialogState<Action>?
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        @available(*, deprecated)
        case setDprColor(ColorIdentifier)
        case setColor(MTColor)
        case setEdit(isPresented: Bool)
        case removeTapped
        case removeConfirmationDismissed
        case delete
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .setDprColor(color):
                state.colorIdentifier = color
                for id in state.players.map(\.id) {
                    var player = state.players[id: id]
                    player?.color = state.color
                    state.players[id: id] = player
                }
                return .none
            case let .setColor(color):
                state.color = color
                for id in state.players.map(\.id) {
                    state.players[id: id]?.color = color
                }
                return .none
            case .binding:
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
        case color
        case imageIdentifier
        case players
    }
}
