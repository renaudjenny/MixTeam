import ComposableArchitecture

struct Scoreboard: ReducerProtocol {
    struct State: Equatable {
        var scores = Scores.State()
        var isLoading = true
        var error: String?
    }

    enum Action: Equatable {
        case task
        case update(TaskResult<Scores.State>)
        case scores(Scores.Action)
    }

    @Dependency(\.scoresPersistence) var scoresPersistence
    @Dependency(\.teamPersistence) var teamPersistence

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.scores, action: /Action.scores) {
            Scores()
        }
        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                return .run { send in
                    await send(.update(TaskResult { try await scoresPersistence.load() }))
                    for try await _ in teamPersistence.publisher() {
                        await send(.update(TaskResult { try await scoresPersistence.load() }))
                    }
                }
            case let .update(result):
                state.isLoading = false
                switch result {
                case let .success(result):
                    state.scores = result
                    return .none
                case let .failure(error):
                    state.error = error.localizedDescription
                    return .none
                }
            case .scores:
                return .none
            }
        }
    }
}
