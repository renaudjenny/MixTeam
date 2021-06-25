import SwiftUI

struct NewScoreView: View {
    let teams: [Team]
    @State var scores: [Round.Score] = []
    let save: ([Round.Score]) -> Void
    let cancel: () -> Void

    var body: some View {
        Form {
            ForEach(scores.indices, id: \.self) { index in
                Section(header: Text(scores[index].team.name)) {
                    TextField(
                        "Score for this team",
                        text: $scores[index].points.string
                    )
                }
            }

            Button { save(scores) } label: {
                Text("Save")
            }

            Button(action: cancel) {
                Text("Cancel")
                    .accentColor(.red)
            }
        }
        .onAppear {
            scores = teams.map { Round.Score(team: $0, points: 0) }
        }
    }
}

struct NewScoreView_Previews: PreviewProvider {
    static var previews: some View {
        NewScoreView(
            teams: Array([Team].exampleTeam.dropFirst()),
            save: { _ in },
            cancel: { }
        )
    }
}
