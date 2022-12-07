import ComposableArchitecture
import Foundation

struct Player: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        @BindableState var name = ""
        @BindableState var image: MTImage = .unknown
        var color: MTColor = .aluminium
        var isStanding = false
        var isArchived = false
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case setEdit(isPresented: Bool)
        case delete
        case moveBack
    }

    @Dependency(\.appPersistence.player) var playerPersistence

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .fireAndForget { [state] in try await playerPersistence.updateOrAppend(state) }
            case .setEdit:
                return .none
            case .delete:
                return .fireAndForget { [state] in try await playerPersistence.remove(state) }
            case .moveBack:
                return .none
            }
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
