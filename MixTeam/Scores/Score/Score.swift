import ComposableArchitecture
import Foundation

struct Score: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        var teamID: Team.State.ID
        @BindableState var points: Int

        var accumulatedPoints = 0
        var teamStatus: TeamStatus = .loading
    }

    enum TeamStatus: Equatable {
        case loading
        case loaded(Team.State)
        case error
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case remove
        case loadTeam
        case teamLoaded(TaskResult<Team.State>)
    }

    @Dependency(\.appPersistence.team) var teamPersistence

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .remove:
                return .none
            case .loadTeam:
                return .task { [state] in
                    await .teamLoaded(TaskResult {
                        try await teamPersistence.load()[id: state.teamID] ?? Team.State(id: state.teamID)
                    })
                }
                .animation(.default)
            case let .teamLoaded(result):
                switch result {
                case let .success(team):
                    state.teamStatus = .loaded(team)
                    return .none
                case .failure:
                    state.teamStatus = .error
                    return .none
                }
            }
        }
    }
}

extension Score.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case teamID
        case points
    }
}
