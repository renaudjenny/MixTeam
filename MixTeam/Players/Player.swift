import ComposableArchitecture
import Foundation

struct Player: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        @BindableState var name = ""
        @BindableState var image: MTImage = .unknown
        var color: MTColor = .aluminium
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
    }

    @Dependency(\.playerPersistence) var playerPersistence

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            if case .binding = action {
                return .fireAndForget { [state] in try await playerPersistence.updateOrAppend(state) }
            }
            return .none
        }
    }
}

extension Player.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case image
    }
}
