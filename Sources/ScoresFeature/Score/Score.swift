import ComposableArchitecture
import Foundation
import Models
import PersistenceCore
import TeamsFeature

@Reducer
public struct Score {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let id: UUID
        public var team: Team.State
        public var points: Int = 0
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

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            if case .binding = action {
                return .run { [state] _ in try await scorePersistence.updateScore(state.persisted)
                }
            }
            return .none
        }
    }
}
