import ComposableArchitecture
import SwiftUI

struct Scores: ReducerProtocol {
    struct State: Equatable, Codable {
        private(set) var teams: IdentifiedArrayOf<Team.State> = []
        var rounds: IdentifiedArrayOf<Round.State> = []
        @BindableState var focusedField: Score.State?
    }

    enum Action: BindableAction, Equatable {
        case addRound
        case recalculateAccumulatedPoints
        case round(id: Round.State.ID, action: Round.Action)
        case minusScore(score: Score.State?)
        case binding(BindingAction<State>)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addRound:
                let roundCount = state.rounds.count
                let scores = IdentifiedArrayOf(uniqueElements: state.teams.map { team in
                    Score.State(
                        id: uuid(),
                        team: team,
                        points: 0,
                        accumulatedPoints: state.accumulatedPoints(for: team, roundCount: roundCount)
                    )
                })
                state.rounds.append(Round.State(id: uuid(), name: "Round \(roundCount + 1)", scores: scores))
                return .none
            case .recalculateAccumulatedPoints:
                for (index, round) in state.rounds.enumerated() {
                    for team in state.rounds[id: round.id]?.teams ?? [] {
                        let accumulatedPoints = state.accumulatedPoints(for: team, roundCount: index + 1)
                        guard let scoreID = state.rounds[id: round.id]?.scores.first(where: { $0.team == team })?.id
                        else { continue }
                        state.rounds[id: round.id]?.scores[id: scoreID]?.accumulatedPoints = accumulatedPoints
                    }
                }
                return .none
            case let .round(id, action: .score(_, action: .remove)):
                if state.rounds[id: id]?.scores.isEmpty == true {
                    state.rounds.remove(id: id)
                }
                return Effect(value: .recalculateAccumulatedPoints)
            case .round(_, .score(_, .binding)):
                return Effect(value: .recalculateAccumulatedPoints)
            case .round:
                return .none
            case let .minusScore(score):
                guard let score,
                      let roundID = state.rounds.first(where: { $0.scores.contains(score) })?.id
                else { return .none }

                state.rounds[id: roundID]?.scores[id: score.id]?.points = -score.points
                return Effect(value: .recalculateAccumulatedPoints)
            case .binding:
                return .none
            }
        }
        .forEach(\.rounds, action: /Action.round) {
            Round()
        }
    }
}

extension App.State {
    var scores: Scores.State {
        get {
            Scores.State(teams: teams, rounds: _scores.rounds)
        }
        set {
            _scores.rounds = newValue.rounds
        }
    }
}

private extension Scores.State {
    func accumulatedPoints(for team: Team.State, roundCount: Int) -> Int {
        guard roundCount > 0, roundCount <= rounds.count else { return 0 }
        return rounds[...(roundCount - 1)].flatMap(\.scores).filter { $0.team == team }.map(\.points).reduce(0, +)
    }
}
