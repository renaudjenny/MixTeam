import ComposableArchitecture
import Models
import PersistenceCore
import SwiftUI
import TeamsFeature

@Reducer
public struct Scores {
    @ObservableState
    public struct State: Equatable {
        public var teams: IdentifiedArrayOf<Team.State> = []
        public var rounds: IdentifiedArrayOf<Round.State> = []
        public var focusedField: Score.State?
    }

    public enum Action: BindableAction, Equatable {
        case task
        case addRound
        case updateAccumulatedPoints(IdentifiedArrayOf<Round.State>)
        case round(id: Round.State.ID, action: Round.Action)
        case minusScore(score: Score.State?)
        case binding(BindingAction<State>)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.scoresPersistence) var scoresPersistence
    @Dependency(\.teamPersistence) var teamPersistence
    private enum CancelID { case recalculateTask }

    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .task:
                return recalculateAccumulatedPoints(state: &state)
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
                return .run { [state] _ in
                    try await scoresPersistence.save(state.persisted)
                }
            case let .updateAccumulatedPoints(rounds):
                state.rounds = rounds
                return .none
            case let .round(id, action: .score(_, action: .remove)):
                if state.rounds[id: id]?.scores.isEmpty == true {
                    state.rounds.remove(id: id)
                }
                return .merge(
                    .run { [state] _ in try await scoresPersistence.save(state.persisted) },
                    recalculateAccumulatedPoints(state: &state)
                )
            case let .round(_, .score(_, .binding(binding))):
                return recalculateAccumulatedPoints(state: &state)
            case .round:
                return .none
            case let .minusScore(score):
                guard let score,
                      let roundID = state.rounds.first(where: { $0.scores.contains(score) })?.id
                else { return .none }

                state.rounds[id: roundID]?.scores[id: score.id]?.points = -score.points
                return .merge(
                    .run { [state] _ in try await scoresPersistence.save(state.persisted) },
                    recalculateAccumulatedPoints(state: &state)
                )
            case .binding:
                return .none
            }
        }
        .forEach(\.rounds, action: /Action.round) {
            Round()
        }
    }

    private func recalculateAccumulatedPoints(state: inout State) -> Effect<Action> {
        .cancel(id: CancelID.recalculateTask).concatenate(with: .run { [rounds = state.rounds] _ in
//            var rounds = rounds
//            for (index, round) in rounds.enumerated() {
//                for team in rounds[id: round.id]?.scores.map(\.team) ?? [] {
//                    let accumulatedPoints = rounds.accumulatedPoints(for: team, roundCount: index + 1)
//                    guard let scoreID = rounds[id: round.id]?.scores.first(where: { $0.team == team })?.id
//                    else { continue }
//                    rounds[id: round.id]?.scores[id: scoreID]?.accumulatedPoints = accumulatedPoints
//                }
//            }
//            return .updateAccumulatedPoints(rounds)
            // TODO: to fix!
        })
        .cancellable(id: CancelID.recalculateTask)
    }
}

private extension IdentifiedArrayOf<Round.State> {
    func accumulatedPoints(for team: Team.State, roundCount: Int) -> Int {
        guard roundCount > 0, roundCount <= count else { return 0 }
        return self[...(roundCount - 1)].flatMap(\.scores).filter { $0.team == team }.map(\.points).reduce(0, +)
    }
}
