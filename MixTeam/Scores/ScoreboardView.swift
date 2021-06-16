import SwiftUI

struct ScoreboardView: View {
    let rounds: [Round]

    var body: some View {
        List {
            Section(header: HeaderView(rounds: rounds)) {
                ForEach(rounds, content: RoundView.init)
            }
        }
    }
}

struct HeaderView: View {
    let rounds: [Round]

    var body: some View {
        HStack {
            Color.clear.frame(width: 100)
            ForEach(teams) {
                Text("\($0.name)")
                    .frame(width: 100)
                    .multilineTextAlignment(.center)
            }
        }
    }

    var teams: [Team] {
        rounds
            .flatMap(\.scores)
            .map(\.team)
            .reduce([], {
                guard !$0.contains($1)
                else { return $0 }
                return $0 + [$1]
            })
    }
}

struct RoundView: View {
    let round: Round

    var body: some View {
        HStack {
            Text(round.name)
                .frame(width: 100)
                .multilineTextAlignment(.trailing)
            ForEach(round.scores) {
                Text("\($0.points)")
                    .frame(width: 100)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct Round: Identifiable {
    let name: String
    let scores: [Score]
    let id = UUID()

    struct Score: Identifiable {
        var team: Team
        var points: Int
        var id: Team.ID { team.id }
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView(rounds: .mock)
    }
}

extension Array where Element == Round {
    static let team1: Team = [Team].exampleTeam[1]
    static let team2: Team = [Team].exampleTeam[2]

    static let mock: Self = {
        [
            Round(
                name: "Round 1",
                scores: [
                    Round.Score(team: team1, points: 0),
                    Round.Score(team: team2, points: 20),
                ]
            ),
            Round(
                name: "Round 2",
                scores: [
                    Round.Score(team: team1, points: 10),
                    Round.Score(team: team2, points: 20),
                ]
            ),
            Round(
                name: "Round 3",
                scores: [
                    Round.Score(team: team1, points: 10),
                    Round.Score(team: team2, points: 50),
                ]
            ),
        ]
    }()
}
