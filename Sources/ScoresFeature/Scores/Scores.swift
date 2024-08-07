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
        case rounds(IdentifiedActionOf<Round>)
        case minusScore(score: Score.State?)
        case binding(BindingAction<State>)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.legacyScoresPersistence) var legacyScoresPersistence
    @Dependency(\.legacyTeamPersistence) var legacyTeamPersistence
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
                    try await legacyScoresPersistence.save(state.persisted)
                }
            case let .updateAccumulatedPoints(rounds):
                state.rounds = rounds
                return .none
            case let .rounds(.element(id, action: .scores(.element(_, action: .remove)))):
                if state.rounds[id: id]?.scores.isEmpty == true {
                    state.rounds.remove(id: id)
                }
                return .merge(
                    .run { [state] _ in try await legacyScoresPersistence.save(state.persisted) },
                    recalculateAccumulatedPoints(state: &state)
                )
            case .rounds(.element(_, action: .scores(.element(_, action: .binding)))):
                return recalculateAccumulatedPoints(state: &state)
            case .rounds:
                return .none
            case let .minusScore(score):
                guard let score,
                      let roundID = state.rounds.first(where: { $0.scores.contains(score) })?.id
                else { return .none }

                state.rounds[id: roundID]?.scores[id: score.id]?.points = -score.points
                return .merge(
                    .run { [state] _ in try await legacyScoresPersistence.save(state.persisted) },
                    recalculateAccumulatedPoints(state: &state)
                )
            case .binding:
                return .none
            }
        }
        .forEach(\.rounds, action: \.rounds) {
            Round()
        }
    }

    private func recalculateAccumulatedPoints(state: inout State) -> Effect<Action> {
        .cancel(id: CancelID.recalculateTask).concatenate(with: .run { [rounds = state.rounds] send in
            var rounds = rounds
            for (index, round) in rounds.enumerated() {
                for team in rounds[id: round.id]?.scores.map(\.team) ?? [] {
                    let accumulatedPoints = rounds.accumulatedPoints(for: team, roundCount: index + 1)
                    guard let scoreID = rounds[id: round.id]?.scores.first(where: { $0.team == team })?.id
                    else { continue }
                    rounds[id: round.id]?.scores[id: scoreID]?.accumulatedPoints = accumulatedPoints
                }
            }
            await send(.updateAccumulatedPoints(rounds))
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
