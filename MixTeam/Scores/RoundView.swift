import ComposableArchitecture
import SwiftUI

struct RoundView: View {
    let store: StoreOf<Scores>
    @Binding var round: Round
    @State private var backup: Round?

    var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Section(header: Text("Name")) {
                    TextField(
                        "Name for this round",
                        text: $round.name
                    )
                }

                ForEach($round.scores) { _, score in
                    Section(header: Text(score.wrappedValue.team.name)) {
                        TextField(
                            "Score for this team",
                            text: score.points.string
                        )
                    }
                }
            }
            .navigationTitle(Text(round.name))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { round = backup ?? round } label: {
                        Text("Reset")
                    }
                }
            }
            .onAppear {
                backup = round

                let teams = (viewStore.teams + round.scores.map(\.team))
                    .reduce([], { result, team -> [Team.State] in
                        if result.contains(where: { $0 == team }) { return result }
                        return result + [team]
                    })

                round.scores = teams.map { team in
                    round.scores.first(where: { $0.team == team })
                    ?? Round.Score(team: team, points: 0)
                }
            }
        }
    }
}

#if DEBUG
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
                    Round.Score(team: App.State.example.teams[2], points: 15),
                ],
                id: id
            )
        }()

        var body: some View {
            VStack {
                NavigationView {
                    RoundView(store: .preview, round: $round)
                }
                VStack(alignment: .leading) {
                    Text("\(round.name)").font(.title3)
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
#endif
