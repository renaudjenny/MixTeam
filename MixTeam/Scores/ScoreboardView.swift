import SwiftUI

struct ScoreboardView: View {
    let scoreLines: [ScoreLine]
    let teams: [Team]

    var body: some View {
        VStack {
            HStack {
                EmptyView().frame(width: 100)
                ForEach(teams) {
                    Text("\($0.name)").frame(width: 100)
                }
            }
            List(scoreLines, rowContent: ScoreLineView.init)
        }
    }
}

struct ScoreLineView: View {
    let scoreLine: ScoreLine

    var body: some View {
        HStack {
            Text(scoreLine.name).frame(width: 100)
            ForEach(scoreLine.scores) {
                Text("\($0.points)").frame(width: 100)
            }
        }
    }
}

struct ScoreLine: Identifiable {
    let name: String
    let scores: [Score]
    var id: String { name }

    struct Score: Identifiable {
        var team: Team
        var points: Int
        var id: Team.ID { team.id }
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView(
            scoreLines: .mock,
            teams: Array([Team].exampleTeam.dropFirst())
        )
    }
}

extension Array where Element == ScoreLine {
    static let team1: Team = [Team].exampleTeam[1]
    static let team2: Team = [Team].exampleTeam[2]

    static let mock: Self = {
        [
            ScoreLine(
                name: "Game 1",
                scores: [
                    ScoreLine.Score(team: team1, points: 0),
                    ScoreLine.Score(team: team2, points: 20),
                ]
            ),
            ScoreLine(
                name: "Game 2",
                scores: [
                    ScoreLine.Score(team: team1, points: 10),
                    ScoreLine.Score(team: team2, points: 20),
                ]
            ),
            ScoreLine(
                name: "Game 3",
                scores: [
                    ScoreLine.Score(team: team1, points: 10),
                    ScoreLine.Score(team: team2, points: 50),
                ]
            ),
        ]
    }()
}
