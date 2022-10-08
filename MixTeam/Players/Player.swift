import ComposableArchitecture
import Foundation

struct Player: ReducerProtocol {
    struct State: Equatable, Identifiable, Codable {
        let id: UUID
        var name = ""
        var image: ImageIdentifier = .unknown
        var isInFirstRow = false
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

struct DprPlayer: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String = ""
    var imageIdentifier: ImageIdentifier
}

#if DEBUG
extension DprPlayer {
    static var test: Self {
        DprPlayer(id: UUID(), name: "Test", imageIdentifier: .girl)
    }
}
#endif
