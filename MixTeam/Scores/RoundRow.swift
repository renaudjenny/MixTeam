import SwiftUI

struct RoundRow: View {
    @Binding var round: Round
    let accumulatedPoints: [Team: Int]

    var body: some View {
        NavigationLink(destination: RoundView(round: $round)) {
            VStack {
                ForEach(round.scores) { score in
                    GeometryReader { geometry in
                        HStack {
                            Text(score.team.name)
                                .frame(width: geometry.size.width * 2/3, alignment: .leading)
                            Spacer()
                            Text("\(score.points)")
                            Spacer()
                            Text("\(accumulatedPoints[score.team] ?? 0)")
                        }
                    }
                }
            }
        }
    }
}

struct RoundRow_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        @State private var round: Round = {
            guard let id = UUID(uuidString: "09756F5B-C236-41FD-B46D-991544F1698A")
            else { fatalError("Cannot generate UUID from a defined UUID String") }

            return Round(
                name: "Test Round",
                scores: [
                    Round.Score(team: [Team].exampleTeam[1], points: 15),
                    Round.Score(team: [Team].exampleTeam[2], points: 20),
                ],
                id: id
            )
        }()

        var body: some View {
            RoundRow(round: $round, accumulatedPoints: [
                [Team].exampleTeam[1]: 20,
                [Team].exampleTeam[2]: 50,
            ])
        }
    }
}
