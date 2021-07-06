import SwiftUI

struct TotalScoresView: View {
    let rounds: [Round]

    var body: some View {
        Section(header: header) {
            ForEach(rounds.teams) { team in
                HStack {
                    Text("\(team.name)")
                    Spacer()
                    ZStack {
                        Text("99999").hidden()
                        Text(total(for: team))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .background(Color.purple.clipShape(Ellipse()))
                }
            }
            .listRowBackground(Color.purple.opacity(20/100))
        }
    }

    private var header: some View {
        HStack {
        Text("Total")
            .font(.title3)
            .fontWeight(.heavy)
            .foregroundColor(.white)
            Spacer()
        }
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.purple)
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
        List {
            TotalScoresView(rounds: .mock)
        }
    }
}
#endif
