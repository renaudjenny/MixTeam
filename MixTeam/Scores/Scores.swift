import ComposableArchitecture
import SwiftUI

struct Scores: ReducerProtocol {
    struct State: Equatable {
        private(set) var teams: IdentifiedArrayOf<Team.State> = []
        var rounds: IdentifiedArrayOf<Round.State> = []
        @BindableState var focusedField: Score.State?
    }

    enum Action: BindableAction, Equatable {
        case addRound
        case recalculateAccumulatedPoints
        case updateAccumulatedPoints(IdentifiedArrayOf<Round.State>)
        case round(id: Round.State.ID, action: Round.Action)
        case minusScore(score: Score.State?)
        case binding(BindingAction<State>)
    }

    @Dependency(\.uuid) var uuid
    private enum RecalculateTaskID {}

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addRound:
                let roundCount = state.rounds.count
                let scores = IdentifiedArrayOf(uniqueElements: state.teams.map { team in
                    Score.State(
                        id: uuid(),
                        teamID: team.id,
                        points: 0,
                        accumulatedPoints: state.rounds.accumulatedPoints(for: team.id, roundCount: roundCount)
                    )
                })
                state.rounds.append(Round.State(id: uuid(), name: "Round \(roundCount + 1)", scores: scores))
                return .none
            case .recalculateAccumulatedPoints:
                return .cancel(id: RecalculateTaskID.self).concatenate(with: .task { [rounds = state.rounds] in
                    var rounds = rounds
                    for (index, round) in rounds.enumerated() {
                        for teamID in rounds[id: round.id]?.scores.map(\.teamID) ?? [] {
                            let accumulatedPoints = rounds.accumulatedPoints(for: teamID, roundCount: index + 1)
                            guard let scoreID = rounds[id: round.id]?.scores.first(where: { $0.teamID == teamID })?.id
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

extension Scores.State: Codable {
    enum CodingKeys: CodingKey {
        case rounds
    }
}

extension App.State {
    var scores: Scores.State {
        get {
            // TODO: it's not correct, address that later
            let teams = IdentifiedArrayOf(uniqueElements: teamRows.compactMap { teamRow -> Team.State? in
                if case let .loaded(team) = teamRow.row { return team } else { return nil }
            })
            return Scores.State(
                teams: teams,
                rounds: _scores.rounds
            )
        }
        set {
            (
                _scores.rounds
            ) = (
                newValue.rounds
            )
        }
    }
}

private extension IdentifiedArrayOf<Round.State> {
    func accumulatedPoints(for teamID: Team.State.ID, roundCount: Int) -> Int {
        guard roundCount > 0, roundCount <= count else { return 0 }
        return self[...(roundCount - 1)].flatMap(\.scores).filter { $0.teamID == teamID }.map(\.points).reduce(0, +)
    }
}
