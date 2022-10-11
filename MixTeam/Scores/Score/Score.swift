import ComposableArchitecture

struct Score: ReducerProtocol {
    struct State: Equatable, Identifiable, Codable {
        let team: Team.State
        var points: Int
        var accumulatedPoints: Int

        var id: Team.State.ID { team.id }
    }

    enum Action: Equatable {
        case pointsUpdated(Int)
        case accumulatedPointsUpdated(Int)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case let .pointsUpdated(points):
            state.points = points
            return .none
        case let .accumulatedPointsUpdated(accumulatedPoints):
            state.accumulatedPoints = accumulatedPoints
            return .none
        }
    }
}
