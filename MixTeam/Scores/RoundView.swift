import SwiftUI

struct RoundView: View {
    @Binding var round: Round
    @EnvironmentObject var teamsStore: TeamsStore
    @State private var backup: Round?
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        Form {
            ForEach($round.scores) { _, score in
                Section(header: Text(score.wrappedValue.team.name)) {
                    TextField(
                        "Score for this team",
                        text: score.points.string
                    )
                }
            }

            Button(action: save) {
                Text("Save")
            }

            Button(action: cancel) {
                Text("Cancel")
                    .accentColor(.red)
            }
        }
        .onAppear {
            backup = round
            round.scores = teams.map { team in
                round.scores.first(where: { $0.team == team })
                    ?? Round.Score(team: team, points: 0)
            }
        }
    }

    private var teams: [Team] {
        (teamsStore.teams.dropFirst() + round.scores.map(\.team))
            .reduce([], { result, team -> [Team] in
                if result.contains(where: { $0 == team }) { return result }
                return result + [team]
            })
    }

    private func save() { presentationMode.wrappedValue.dismiss() }
    private func cancel() {
        round = backup ?? round
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewScoreView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        @State private var round: Round = {
            guard let id = UUID(uuidString: "881B7BC5-1BA6-4DDB-9C60-ACCDC4D87762")
            else { fatalError("Cannot generate UUID from a defined UUID String") }

            return Round(
                name: "Round 1",
                scores: [
                    Round.Score(team: [Team].exampleTeam[2], points: 15),
                ],
                id: id
            )
        }()

        var body: some View {
            VStack {
                RoundView(round: $round).environmentObject(TeamsStore())
                Section(header: Text("Result")) {
                    ForEach(round.scores) { score in
                        HStack {
                            Text("\(score.team.name)")
                            Text("\(score.points)")
                        }
                    }
                }
            }
        }
    }
}
