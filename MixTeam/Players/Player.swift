import ComposableArchitecture
import Foundation

struct Player: ReducerProtocol {
    struct State: Equatable, Identifiable, Codable {
        let id: UUID
        var name = ""
        var image: ImageIdentifier = .unknown
        var isStanding = false
        let color: ColorIdentifier
    }

    enum Action: Equatable {
        case edit
        case delete
        case moveBack
        case nameUpdated(String)
        case imageUpdated(ImageIdentifier)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .edit:
            return .none
        case .delete:
            return .none
        case .moveBack:
            return .none
        case let .nameUpdated(name):
            state.name = name
            return .none
        case let .imageUpdated(image):
            state.image = image
            return .none
        }
    }
}
