import SwiftUI

struct ScoreboardView: View {
    @AppStorage("Scores.rounds") var rounds: Rounds = []

    var body: some View {
        NavigationView {
            List {
                ForEach(rounds.indices, id: \.self) { roundIdx in
                    Section(
                        header: HeaderView(roundName: rounds[roundIdx].name),
                        footer: FooterView(scores: $rounds[roundIdx].scores)
                    ) {
                        ForEach(rounds[roundIdx].scores.indices, id: \.self) { scoreIdx in
                            ScoreRow(score: $rounds[roundIdx].scores[scoreIdx])
                        }
                        .onDelete { rounds.remove(atOffsets: $0) }
                    }
                }
                TotalView(rounds: rounds)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addRound) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func remove(atOffsets: IndexSet) {
        rounds.remove(atOffsets: atOffsets)
    }

    private func addRound() {
        rounds.append(Round(name: "Round \(rounds.count + 1)", scores: []))
    }
}

struct HeaderView: View {
    let roundName: String

    var body: some View {
        Text(roundName)
    }
}

struct ScoreRow: View {
    @Binding var score: Round.Score
    @State private var editedScore = Round.Score(team: .empty, points: 0)
    @State private var isEditionPresented = false

    var body: some View {
        Button {
            editedScore = score
            isEditionPresented = true
        } label: {
            HStack {
                Text(score.team.name)
                    .frame(width: 100)
                Text("\(score.points)")
                    .frame(width: 100)
            }
        }
        .sheet(isPresented: $isEditionPresented) {
            EditScoreView(
                score: $editedScore,
                save: {
                    score = editedScore
                    isEditionPresented = false
                },
                cancel: { isEditionPresented = false }
            )
        }
    }
}

struct Round: Identifiable, Codable {
    var name: String
    var scores: [Score]
    var id = UUID()

    struct Score: Identifiable, Codable {
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

struct FooterView: View {
    @Binding var scores: [Round.Score]
    @EnvironmentObject var teamsStore: TeamsStore
    @State private var isNewViewPresented = false

    var body: some View {
        if selectableTeams.count > 0 {
            HStack {
                Button { isNewViewPresented = true } label: {
                    Label("Add a new score", systemImage: "plus")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(4)
                .background(Color.gray.opacity(20/100))
                .cornerRadius(5)
                .padding(4)

                Spacer()
            }
            .sheet(isPresented: $isNewViewPresented) {
                NewScoreView(
                    teams: selectableTeams,
                    save: {
                        scores = $0
                        isNewViewPresented = false
                    },
                    cancel: { isNewViewPresented = false }
                )
            }
        } else {
            EmptyView()
        }
    }

    var selectableTeams: [Team] {
        teamsStore.teams
            .dropFirst()
            .filter {
                !scores.map(\.team).contains($0)
            }
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

struct EditScoreView: View {
    @Binding var score: Round.Score
    @EnvironmentObject var teamsStore: TeamsStore
    let save: () -> Void
    let cancel: () -> Void

    var body: some View {
        Form {
            Section(header: Text(score.team.name)) {
                TextField(
                    "Score for this team",
                    text: $score.points.string
                )
            }

            Button(action: save) {
                Text("Save")
            }

            Button(action: cancel) {
                Text("Cancel")
                    .accentColor(.red)
            }
        }
    }

    var teams: [Team] {
        (teamsStore.teams.dropFirst() + [score.team])
            .reduce([], { result, team -> [Team] in
                if result.contains(where: { $0 == team }) { return result }
                return result + [team]
            })
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
