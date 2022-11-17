import ComposableArchitecture
import Foundation

struct Player: ReducerProtocol {
    struct State: Equatable, Identifiable, Codable {
        let id: UUID
        var name = ""
        var image: ImageIdentifier = .unknown
        var isStanding = false
        var color: ColorIdentifier
    }

    enum Action: Equatable {
        case setName(String)
        case setImage(ImageIdentifier)
        case setEdit(isPresented: Bool)
        case delete
        case moveBack
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .setName(name):
            state.name = name
            return .none
        case let .setImage(image):
            state.image = image
            return .none
        case .setEdit:
            return .none
        case .delete:
            return .none
        case .moveBack:
            return .none
        }
    }
}
