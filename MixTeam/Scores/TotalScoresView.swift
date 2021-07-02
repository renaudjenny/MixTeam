import SwiftUI

struct TotalScoresView: View {
    let rounds: [Round]

    var body: some View {
        Section(header: Text("Total")) {
            ForEach(rounds.teams) { team in
                HStack {
                    Text("\(team.name)")
                        .bold()
                        .frame(width: 100)
                    Text(total(for: team))
                        .bold()
                        .frame(width: 100)
                }
            }
        }
    }

    private func total(for team: Team) -> String {
        String(
            rounds
                .flatMap(\.scores)
                .filter { $0.id == team.id }
                .map(\.points)
                .reduce(0, +)
        )
    }
}

#if DEBUG
struct TotalScoresView_Previews: PreviewProvider {
    static var previews: some View {
        TotalScoresView(rounds: .mock)
    }
}
#endif
