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

                TotalView(rounds: rounds)
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

struct TotalView: View {
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

extension Array where Element == Round {
    static let team1: Team = [Team].exampleTeam[1]
    static let team2: Team = [Team].exampleTeam[2]
    static let team3 = Team(
        name: "The team who had no name",
        colorIdentifier: .red,
        imageIdentifier: .hippo,
        players: []
    )

    static let mock: Self = {
        [
            Round(
                name: "Round 1",
                scores: [
                    Round.Score(team: team1, points: 0),
                    Round.Score(team: team2, points: 20),
                ]
            ),
            Round(
                name: "Round 2",
                scores: [
                    Round.Score(team: team1, points: 10),
                    Round.Score(team: team2, points: 20),
                ]
            ),
            Round(
                name: "Round 3",
                scores: [
                    Round.Score(team: team1, points: 10),
                    Round.Score(team: team2, points: 50),
                ]
            ),
            Round(
                name: "Round 4",
                scores: [
                    Round.Score(team: team1, points: 10),
                    Round.Score(team: team2, points: 50),
                    Round.Score(team: team3, points: 15),
                ]
            ),
        ]
    }()

    var teams: [Team] {
        flatMap(\.scores)
            .map(\.team)
            .reduce([], {
                guard !$0.contains($1)
                else { return $0 }
                return $0 + [$1]
            })
    }
}

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
