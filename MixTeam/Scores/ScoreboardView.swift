import SwiftUI

struct ScoreboardView: View {
    @AppStorage("Scores.rounds") var rounds: Rounds = []
    @Environment(\.presentationMode) private var presentationMode
    @State private var isNavigateToNewRoundActive = false

    var body: some View {
        NavigationView {
            List {
                ForEach($rounds) { _, round in
                    Section(header: HeaderView(roundName: round.wrappedValue.name)) {
                        RoundRow(
                            round: round,
                            accumulatedPoints: accumulatedPoints(for: round.wrappedValue)
                        )
                    }
                }
                .onDelete { rounds.remove(atOffsets: $0) }

                TotalScoresView(rounds: rounds)
            }
            .navigationTitle(Text("Scoreboard"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addRound) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .background(navigationToNew())
        }
    }

    private func remove(atOffsets: IndexSet) {
        rounds.remove(atOffsets: atOffsets)
    }

    private func addRound() {
        rounds.append(Round(name: "Round \(rounds.count + 1)", scores: []))
        isNavigateToNewRoundActive = true
    }

    private func accumulatedPoints(for round: Round) -> [Team: Int] {
        guard let roundIndex = rounds.firstIndex(of: round)
        else { return [:] }
        return [Team: Int](
            rounds[...roundIndex].flatMap(\.scores).map { score -> (Team, Int) in
                (score.team, score.points)
            },
            uniquingKeysWith: { $0 + $1 }
        )
    }

    @ViewBuilder
    private func navigationToNew() -> some View {
        if rounds.count > 0 {
            NavigationLink(
                destination: RoundView(round: $rounds[rounds.count - 1]),
                isActive: $isNavigateToNewRoundActive,
                label: EmptyView.init
            )
        }
    }
}

struct HeaderView: View {
    let roundName: String

    var body: some View {
        Text(roundName)
    }
}

#if DEBUG
struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        @AppStorage("Scores.rounds") var rounds: Rounds = []

        var body: some View {
            VStack {
                ScoreboardView(rounds: .mock)
                    .environmentObject(TeamsStore())
                Button("Reset App Storage") {
                    rounds = .mock
                }
                .accentColor(.red)
            }
        }
    }
}
#endif
