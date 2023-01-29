import ComposableArchitecture
import Foundation

struct Round: ReducerProtocol {
    struct State: Identifiable, Equatable, Hashable {
        let id: UUID
        @BindableState var name: String
        var scores: IdentifiedArrayOf<Score.State> = []
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case score(id: Score.State.ID, action: Score.Action)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.scoresPersistence.updateRound) var updateRound

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .fireAndForget { [state] in try await updateRound(state) }
            case let .score(id: id, action: .remove):
                state.scores.remove(id: id)
                return .none
            case .score:
                return .none
            }
        }
        .forEach(\.scores, action: /Round.Action.score) {
            Score()
        }
    }
}

extension Round.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case scores
    }
}
