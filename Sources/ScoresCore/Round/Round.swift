import ComposableArchitecture
import Foundation

struct Round: ReducerProtocol {
    struct State: Identifiable, Equatable, Hashable {
        let id: UUID
        @BindingState var name: String
        var scores: IdentifiedArrayOf<Score.State> = []
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case score(id: Score.State.ID, action: Score.Action)
    }

    @Dependency(\.scoresPersistence.updateRound) var updateRound

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .fireAndForget { [state] in try await updateRound(state.toPersist) }
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

extension Round.State {
    var toPersistent: Round {
        Round(id: id, name: name, scores: scores)
    }
}
