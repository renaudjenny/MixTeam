import SwiftUI

struct ScoreboardView: View {
    @AppStorage("Scores.rounds") var rounds: Rounds = []

    var body: some View {
        List {
            Section(header: HeaderView(rounds: rounds), footer: FooterView(rounds: $rounds)) {
                ForEach(rounds.indices) {
                    RoundView(round: $rounds[$0])
                }
                .onDelete { rounds.remove(atOffsets: $0) }
            }
        }
    }

    private func remove(atOffsets: IndexSet) {
        rounds.remove(atOffsets: atOffsets)
    }
}

struct HeaderView: View {
    let rounds: [Round]

    var body: some View {
        HStack {
            Color.clear.frame(width: 100)
            ForEach(rounds.teams) {
                Text("\($0.name)")
                    .frame(width: 100)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct RoundView: View {
    @Binding var round: Round
    @State private var editedRound = Round(name: "", scores: [])
    @State private var isEditionPresented = false

    var body: some View {
        Button {
            editedRound = round
            isEditionPresented = true
        } label: {
            HStack {
                Text(round.name)
                    .frame(width: 100)
                ForEach(round.scores) {
                    Text("\($0.points)")
                        .frame(width: 100)
                }
            }
        }
        .sheet(isPresented: $isEditionPresented) {
            EditRoundView(
                round: $editedRound,
                save: {
                    round = editedRound
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
    @Binding var rounds: [Round]
    @State private var isNewRoundPresented = false
    @State private var newRound = Round(name: "", scores: [])

    var body: some View {
        VStack {
            HStack {
                Button(action: addRound) {
                    Label("Add a new round", systemImage: "plus")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(4)
                .background(Color.gray.opacity(20/100))
                .cornerRadius(5)
                .padding(4)

                Spacer()
            }
            Divider()
            HStack {
                Text("Total")
                    .bold()
                    .frame(width: 100)
                ForEach(rounds.teams) { team in
                    VStack {
                        Text("\(team.name)")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                        Text(total(for: team))
                            .bold()
                    }
                    .frame(width: 100)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $isNewRoundPresented) {
            EditRoundView(
                round: $newRound,
                save: {
                    rounds.append(newRound)
                    isNewRoundPresented = false
                },
                cancel: {
                    isNewRoundPresented = false
                }
            )
        }
    }

    private func addRound() {
        newRound = Round(
            name: "Round \(rounds.count + 1)",
            scores: rounds.teams.map {
                Round.Score(team: $0, points: 0)
            }
        )
        isNewRoundPresented = true
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

struct EditRoundView: View {
    @Binding var round: Round
    @EnvironmentObject var teamsStore: TeamsStore
    let save: () -> Void
    let cancel: () -> Void

    var body: some View {
        Form {
            TextField("Round name", text: $round.name)

            ForEach(scores.indices) { scoreIndex in
                Section(header: Text(scores[scoreIndex].team.name)) {
                    TextField(
                        "Score for this team",
                        text: points(scoreIndex: scoreIndex)
                    )
                }
            }

            Button(action: save) {
                Text("Save")
            }

            Button(action: cancel) {
                Text("Cancel")
            }
        }
    }

    func points(scoreIndex: Int) -> Binding<String> {
        Binding<String>(
            get: { String(scores[scoreIndex].points) },
            set: {
                round.scores = scores
                round.scores[scoreIndex].points = Int($0)
                    ?? scores[scoreIndex].points
            }
        )
    }

    var scores: [Round.Score] {
        get {
            (round.scores + teamsStore.teams.dropFirst().map { Round.Score(team: $0, points: 0) })
                .reduce([], { result, score -> [Round.Score] in
                    if result.contains(where: { $0.team == score.team }) { return result }
                    return result + [score]
                })
        }
        set {
            round.scores = newValue
        }
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView(rounds: .mock)
            .environmentObject(TeamsStore())
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
            )
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
