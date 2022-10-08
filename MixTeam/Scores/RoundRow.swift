import SwiftUI

struct RoundRow: View {
    let round: Round
    let accumulatedPoints: [DprTeam: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(round.scores, content: line)
        }
        .listRowInsets(EdgeInsets())
    }

    private func line(score: Round.Score) -> some View {
        VStack(spacing: 0) {
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
            .padding(12)

            if round.scores.last != score {
                Color.white.frame(height: 2)
            }
        }
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
                    Round.Score(team: [DprTeam].exampleTeam[1], points: 15),
                    Round.Score(team: [DprTeam].exampleTeam[2], points: 20),
                    Round.Score(team: [DprTeam].exampleTeam[3], points: 0),
                ],
                id: id
            )
        }()

        var body: some View {
            NavigationView {
                List {
                    ForEach(0..<3) { _ in
                        Section(header: HeaderView(round: .constant(round))) {
                            RoundRow(round: round, accumulatedPoints: [
                                [DprTeam].exampleTeam[1]: 20,
                                [DprTeam].exampleTeam[2]: 50,
                                [DprTeam].exampleTeam[3]: 0,
                            ])
                        }
                    }
                    .listRowBackground(Color.purple.opacity(20/100))
                }
                .navigationTitle(Text("Round row preview"))
            }
        }
    }
}
