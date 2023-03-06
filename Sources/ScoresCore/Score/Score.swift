import ComposableArchitecture
import Foundation
import PersistenceCore
import TeamsCore

public struct Score: ReducerProtocol {
    public typealias Team = TeamsCore.Team

    public struct State: Equatable, Identifiable {
        public let id: UUID
        public var team: Team.State
        @BindingState public var points: Int = 0
        public var accumulatedPoints = 0
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case remove
    }

    @Dependency(\.scoresPersistence) var scorePersistence

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            if case let .binding(binding) = action, binding.keyPath == \.$points {
                return .fireAndForget { [state] in try await scorePersistence.updateScore(state.toPersist) }
            }
            return .none
        }
    }
}

extension Score.State {
    var toPersist: PersistenceCore.Score {
        PersistenceCore.Score(id: id, teamID: team.id, points: points)
    }
}
