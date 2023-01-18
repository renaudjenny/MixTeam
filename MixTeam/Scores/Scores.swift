import ComposableArchitecture
import SwiftUI

// TODO: Split Scores in two ReducerProtocol, one to load the data and manage errors, the other with the logic of Scores
struct Scores: ReducerProtocol {
    struct State: Equatable {
        var teams: IdentifiedArrayOf<Team.State> = []
        var rounds: IdentifiedArrayOf<Round.State> = []
        @BindableState var focusedField: Score.State?
        var isLoading = true
        var error: String?
    }

    enum Action: BindableAction, Equatable {
        case task
        case update(TaskResult<Scores.State>)
        case addRound
        case recalculateAccumulatedPoints
        case updateAccumulatedPoints(IdentifiedArrayOf<Round.State>)
        case round(id: Round.State.ID, action: Round.Action)
        case minusScore(score: Score.State?)
        case binding(BindingAction<State>)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.scoresPersistence) var scoresPersistence
    private enum RecalculateTaskID {}

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                return .run { @MainActor send in
                    await send(.update(TaskResult { try await scoresPersistence.load() }))
                    send(.recalculateAccumulatedPoints)
                    // Listen to Team changes
                }
            case let .update(result):
                state.isLoading = false
                switch result {
                case let .success(result):
                    state.teams = result.teams
                    state.rounds = result.rounds
                    return .none
                case let .failure(error):
                    state.error = error.localizedDescription
                    return .none
                }
            case .addRound:
                let roundCount = state.rounds.count
                let scores = IdentifiedArrayOf(uniqueElements: state.teams.filter { !$0.isArchived }.map { team in
                    Score.State(
                        id: uuid(),
                        team: team,
                        points: 0,
                        accumulatedPoints: state.rounds.accumulatedPoints(for: team, roundCount: roundCount)
                    )
                })
                state.rounds.append(Round.State(id: uuid(), name: "Round \(roundCount + 1)", scores: scores))
                return .fireAndForget { [state] in
                    try await scoresPersistence.save(state)
                }

            case .recalculateAccumulatedPoints:
                // swiftlint:disable:next line_length
                // TODO: should extract this action into a function in the feature, see: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/performance#Sharing-logic-with-actions
                return .cancel(id: RecalculateTaskID.self).concatenate(with: .task { [rounds = state.rounds] in
                    var rounds = rounds
                    for (index, round) in rounds.enumerated() {
                        for team in rounds[id: round.id]?.scores.map(\.team) ?? [] {
                            let accumulatedPoints = rounds.accumulatedPoints(for: team, roundCount: index + 1)
                            guard let scoreID = rounds[id: round.id]?.scores.first(where: { $0.team == team })?.id
                            else { continue }
                            rounds[id: round.id]?.scores[id: scoreID]?.accumulatedPoints = accumulatedPoints
                        }
                    }
                    return .updateAccumulatedPoints(rounds)
                })
                .cancellable(id: RecalculateTaskID.self)
            case let .updateAccumulatedPoints(rounds):
                state.rounds = rounds
                return .none
            case let .round(id, action: .score(_, action: .remove)):
                if state.rounds[id: id]?.scores.isEmpty == true {
                    state.rounds.remove(id: id)
                }
                return .task { [state] in
                    try await scoresPersistence.save(state)
                    return .recalculateAccumulatedPoints
                }
            case .round(_, .score(_, .binding)):
                return .task { [state] in
                    try await scoresPersistence.save(state)
                    return .recalculateAccumulatedPoints
                }
            case .round:
                return .none
            case let .minusScore(score):
                guard let score,
                      let roundID = state.rounds.first(where: { $0.scores.contains(score) })?.id
                else { return .none }

                state.rounds[id: roundID]?.scores[id: score.id]?.points = -score.points
                return .task { [state] in
                    try await scoresPersistence.save(state)
                    return .recalculateAccumulatedPoints
                }
            case .binding:
                return .none
            }
        }
        .forEach(\.rounds, action: /Action.round) {
            Round()
        }
    }
}

private extension IdentifiedArrayOf<Round.State> {
    func accumulatedPoints(for team: Team.State, roundCount: Int) -> Int {
        guard roundCount > 0, roundCount <= count else { return 0 }
        return self[...(roundCount - 1)].flatMap(\.scores).filter { $0.team == team }.map(\.points).reduce(0, +)
    }
}
