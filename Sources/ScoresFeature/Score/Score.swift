import ComposableArchitecture
import Foundation
import Models
import PersistenceCore
import TeamsCore

public struct Score: ReducerProtocol {
    public typealias Team = TeamsCore.Team

    public struct State: Equatable, Identifiable {
        public let id: UUID
        public var team: Team.State
        @BindingState public var points: Int = 0
        public var accumulatedPoints = 0

        public init(id: UUID, team: Team.State, points: Int = 0, accumulatedPoints: Int = 0) {
            self.id = id
            self.team = team
            self.points = points
            self.accumulatedPoints = accumulatedPoints
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case remove
    }

    @Dependency(\.scoresPersistence) var scorePersistence

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            if case let .binding(binding) = action, binding.keyPath == \.$points {
                return .fireAndForget { [state] in try await scorePersistence.updateScore(state.persisted) }
            }
            return .none
        }
    }
}

extension Score.State {
    var persisted: PersistedScore {
        PersistedScore(id: id, teamID: team.id, points: points)
    }
}
