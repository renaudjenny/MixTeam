import ComposableArchitecture
import Foundation

struct Round: ReducerProtocol {
    struct State: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var scores: IdentifiedArrayOf<Score.State> = []
        var backup = Data()

        var teams: IdentifiedArrayOf<Team.State> { IdentifiedArrayOf(uniqueElements: scores.map(\.team)) }
    }

    enum Action: Equatable {
        case nameUpdated(String)
        case start
        case restoreBackup
        case score(id: Score.State.ID, action: Score.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .nameUpdated(name):
                state.name = name
                return .none
            case .start:
                state.backup = (try? JSONEncoder().encode(state)) ?? Data()

                let teams = (state.teams + state.scores.map(\.team))
                    .reduce([], { result, team -> [Team.State] in
                        if result.contains(where: { $0 == team }) { return result }
                        return result + [team]
                    })

                state.scores = IdentifiedArrayOf(uniqueElements: teams.map { team in
                    state.scores.first(where: { $0.team == team })
                    ?? Score.State(team: team, points: 0, accumulatedPoints: 0)
                })
                return .none
            case .restoreBackup:
                guard let backup = try? JSONDecoder().decode(State.self, from: state.backup) else { return .none }
                state = backup
                return .none
            case let .score(id: id, action: .remove):
                state.scores.remove(id: id)
                return .none
            case .score:
                return .none
            }
        }
        .forEach(\.scores, action: /Round.Action.score) {
            Score()
        }
    }
}

extension Array where Element == Round.State {
    var teams: [Team.State] {
        flatMap(\.scores)
            .map(\.team)
            .reduce([], {
                guard !$0.contains($1)
                else { return $0 }
                return $0 + [$1]
            })
    }

    #if DEBUG
    static let mock: Self = {
        guard let thirdTeamID = UUID(uuidString: "21E5DDC4-7EDD-4F54-8DFA-B20BC396A12B"),
              let round1ID = UUID(uuidString: "D52863B0-B133-4380-A824-378839C8E996"),
              let round2ID = UUID(uuidString: "1D698816-025B-4E6A-907D-BEDF1BFB43C7"),
              let round3ID = UUID(uuidString: "0EA3AEDB-E598-4240-81DC-709D79E96783"),
              let round4ID = UUID(uuidString: "9FD2F46F-1A0D-4CA6-80ED-91A012C2D56E")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        let team1: Team.State = App.State.example.teams[1]
        let team2: Team.State = App.State.example.teams[2]
        let team3 = Team.State(
            id: thirdTeamID,
            name: "The team who had no name",
            colorIdentifier: .red,
            imageIdentifier: .hippo,
            players: []
        )

        return [
            Round.State(
                id: round1ID,
                name: "Round 1",
                scores: [
                    Score.State(team: team1, points: 0, accumulatedPoints: 0),
                    Score.State(team: team2, points: 20, accumulatedPoints: 20),
                ]
            ),
            Round.State(
                id: round2ID,
                name: "Round 2",
                scores: [
                    Score.State(team: team1, points: 10, accumulatedPoints: 10),
                    Score.State(team: team2, points: 20, accumulatedPoints: 40),
                ]
            ),
            Round.State(
                id: round3ID,
                name: "Round 3",
                scores: [
                    Score.State(team: team1, points: 10, accumulatedPoints: 30),
                    Score.State(team: team2, points: 50, accumulatedPoints: 90),
                ]
            ),
            Round.State(
                id: round4ID,
                name: "Round 4",
                scores: [
                    Score.State(team: team1, points: 10, accumulatedPoints: 40),
                    Score.State(team: team2, points: 50, accumulatedPoints: 140),
                    Score.State(team: team3, points: 15, accumulatedPoints: 15),
                ]
            ),
        ]
    }()
    #endif
}
