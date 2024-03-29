import ComposableArchitecture
import Foundation
import Models
import PersistenceCore

public struct Round: ReducerProtocol {
    public struct State: Identifiable, Equatable, Hashable {
        public let id: UUID
        @BindingState public var name: String
        public var scores: IdentifiedArrayOf<Score.State> = []

        public init(id: UUID, name: String, scores: IdentifiedArrayOf<Score.State> = []) {
            self.id = id
            self.name = name
            self.scores = scores
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case score(id: Score.State.ID, action: Score.Action)
    }

    @Dependency(\.scoresPersistence.updateRound) var updateRound

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .fireAndForget { [state] in try await updateRound(state.persisted) }
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
    var persisted: PersistedRound {
        PersistedRound(id: id, name: name, scores: IdentifiedArrayOf(uniqueElements: scores.map(\.persisted)))
    }
}
