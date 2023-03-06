import ComposableArchitecture
import Foundation
import PersistenceCore

public struct Round: ReducerProtocol {
    public struct State: Identifiable, Equatable, Hashable {
        public let id: UUID
        @BindingState public var name: String
        public var scores: IdentifiedArrayOf<Score.State> = []
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case score(id: Score.State.ID, action: Score.Action)
    }

    @Dependency(\.scoresPersistence.updateRound) var updateRound

    public var body: some ReducerProtocol<State, Action> {
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
    var toPersist: PersistenceCore.Round {
        PersistenceCore.Round(id: id, name: name, scores: IdentifiedArrayOf(uniqueElements: scores.map(\.toPersist)))
    }
}
