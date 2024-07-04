import ComposableArchitecture
import Foundation
import Models
import PersistenceCore

@Reducer
public struct Round {
    @ObservableState
    public struct State: Identifiable, Equatable, Hashable {
        public let id: UUID
        public var name: String
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

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .run { [state] _ in try await updateRound(state.persisted) }
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
