import ComposableArchitecture
import SwiftUI

struct Scores: ReducerProtocol {
    struct State: Equatable, Codable {
        private(set) var teams: IdentifiedArrayOf<Team.State> = []
        var rounds: IdentifiedArrayOf<Round.State> = []
    }

    enum Action: Equatable {
        case addRound
        case recalculateAccumulatedPoints
        case round(id: Round.State.ID, action: Round.Action)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .addRound:
                let roundCount = state.rounds.count
                let scores = IdentifiedArrayOf(uniqueElements: state.teams.map { team in
                    Score.State(
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
                        state.rounds[id: round.id]?.scores[id: team.id]?.accumulatedPoints = accumulatedPoints
                    }
                }
                return .none
            case let .round(id, action: .remove):
                state.rounds.remove(id: id)
                return Effect(value: .recalculateAccumulatedPoints)
            case .round(_, .score(_, .pointsUpdated)):
                return Effect(value: .recalculateAccumulatedPoints)
            case .round:
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
