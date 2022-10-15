import ComposableArchitecture
import Foundation

struct Player: ReducerProtocol {
    struct State: Equatable, Identifiable, Codable {
        let id: UUID
        @BindableState var name = ""
        @BindableState var image: ImageIdentifier = .unknown
        var isStanding = false
        let color: ColorIdentifier
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case edit
        case delete
        case moveBack
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .edit:
                return .none
            case .delete:
                return .none
            case .moveBack:
                return .none
            }
        }
    }
}
