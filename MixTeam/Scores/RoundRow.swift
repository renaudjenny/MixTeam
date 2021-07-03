import SwiftUI

struct RoundRow: View {
    let round: Round
    let accumulatedPoints: [Team: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            ForEach(round.scores, content: line)
        }
    }

    private func line(score: Round.Score) -> some View {
        HStack {
            HStack {
                Text(score.team.name)
                Spacer()
            }
            HStack {
                Spacer()
                Text("+\(score.points)")
                Spacer()
                Text("\(accumulatedPoints[score.team] ?? 0)")
                    .bold()
            }
        }
        .padding(.vertical)
    }
}

struct RoundRow_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        let round: Round = {
            guard let id = UUID(uuidString: "09756F5B-C236-41FD-B46D-991544F1698A")
            else { fatalError("Cannot generate UUID from a defined UUID String") }

            return Round(
                name: "Test Round",
                scores: [
                    Round.Score(team: [Team].exampleTeam[1], points: 15),
                    Round.Score(team: [Team].exampleTeam[2], points: 20),
                    Round.Score(team: [Team].exampleTeam[3], points: 0),
                ],
                id: id
            )
        }()

        var body: some View {
            NavigationView {
                List {
                    ForEach(0..<3) { _ in
                        RoundRow(round: round, accumulatedPoints: [
                            [Team].exampleTeam[1]: 20,
                            [Team].exampleTeam[2]: 50,
                            [Team].exampleTeam[3]: 0,
                        ])
                    }
                    .listRowBackground(Color.purple.opacity(20/100))
                }
                .navigationTitle(Text("Round row preview"))
            }
        }
    }
}
