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

struct Round: Identifiable, Codable, Hashable {
    var name: String
    var scores: [Score]
    var id = UUID()

    struct Score: Identifiable, Codable, Hashable {
        var team: Team
        var points: Int
        var id: Team.ID { team.id }
    }
}

typealias Rounds = [Round]
extension Rounds: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(Rounds.self, from: data)
        else { return nil }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else { return "[]" }
        return result
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

extension Team {
    static let empty: Team = {
        guard let id = UUID(uuidString: "CDB7B99F-B178-484B-990C-E1B1F1A05F9E")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        return Team(
            id: id,
            name: "-",
            colorIdentifier: .blue,
            imageIdentifier: .elephant,
            players: []
        )
    }()
}

extension Binding where Value == Int {
    var string: Binding<String> {
        Binding<String>(
            get: { String(wrappedValue) },
            set: { wrappedValue = Int($0) ?? wrappedValue }
        )
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
