import ComposableArchitecture
import LoaderCore
import PersistenceCore

public struct Scoreboard: ReducerProtocol {
    public enum State: Equatable {
        case loadingCard
        case loaded(Scores.State)
        case errorCard(ErrorCard.State)
    }

    public enum Action: Equatable {
        case update(TaskResult<Scores.State>)
        case loadingCard(LoadingCard.Action)
        case scores(Scores.Action)
        case errorCard(ErrorCard.Action)
    }

    @Dependency(\.scoresPersistence) var scoresPersistence
    @Dependency(\.teamPersistence) var teamPersistence

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .update(result):
                switch result {
                case let .success(result):
                    state = .loaded(result)
                    return .none
                case let .failure(error):
                    state = .errorCard(ErrorCard.State(description: error.localizedDescription))
                    return .none
                }
            case .loadingCard:
                return load(state: &state).concatenate(with: .run { send in
                    for try await _ in teamPersistence.publisher() {
                        await send(.update(TaskResult { try await scoresPersistence.load() }))
                    }
                })
            case .scores:
                return .none
            case .errorCard(.reload):
                return load(state: &state)
            }
        }
        .ifCaseLet(/State.loadingCard, action: /Action.loadingCard) {
            LoadingCard()
        }
        .ifCaseLet(/State.loaded, action: /Action.scores) {
            Scores()
        }
        .ifCaseLet(/State.errorCard, action: /Action.errorCard) {
            ErrorCard()
        }
    }

    private func load(state: inout State) -> EffectTask<Action> {
        state = .loadingCard
        return .task { await .update(TaskResult { try await scoresPersistence.load() }) }
    }

//    private func loadScores() async throws -> TaskResult<Scores.State> {
//        TaskResult {
//            let scores = try await scoresPersistence.load()
//            let teams = try await teamPersistence.load()
//
//            return .loaded(Scores.State(
//                teams: teams,
//                rounds: IdentifiedArrayOf(uniqueElements: scores.rounds.map { Round.State(
//                    id: $0.id,
//                    name: $0.name,
//                    scores: IdentifiedArrayOf(uniqueElements: $0.scores.map { Score.State(
//                        id: $0.id,
//                        team: <#T##Score.Team.State#>,
//                        points: <#T##Int#>,
//                        accumulatedPoints: 0
//                    ) }
//                ) }
//            ))
//        }
//    }
}
