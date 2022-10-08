import SwiftUI

struct ScoreboardView: View {
    @AppStorage("Scores.rounds") var rounds: Rounds = []
    @EnvironmentObject var teamsStore: TeamsStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var isNavigateToNewRoundActive = false

    var body: some View {
        NavigationView {
            ZStack {
                if rounds.count > 0 {
                    list
                } else {
                    VStack {
                        Text("Add your first round by tapping on the plus button")
                            .foregroundColor(.gray)
                        addRoundButton
                    }
                    .padding()
                }
            }
            .navigationTitle(Text("Scoreboard"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        addRoundButton
                        Spacer()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    doneButton
                }
            }
            .background(navigationToNew())
        }
    }

    private var list: some View {
        List {
            ForEach($rounds) { _, round in
                Section(header: HeaderView(round: round)) {
                    RoundRow(
                        round: round.wrappedValue,
                        accumulatedPoints: accumulatedPoints(for: round.wrappedValue)
                    )
                }
            }
            .onDelete { rounds.remove(atOffsets: $0) }
            .listRowBackground(Color.purple.opacity(20/100))

            TotalScoresView(rounds: rounds)
        }
        .listStyle(.plain)
    }

    private func remove(atOffsets: IndexSet) {
        rounds.remove(atOffsets: atOffsets)
    }

    private func addRound() {
        let scores = teamsStore.teams
            .dropFirst()
            .map { team in Round.Score(team: team, points: 0) }
        rounds.append(Round(name: "Round \(rounds.count + 1)", scores: scores))
        isNavigateToNewRoundActive = true
    }

    private func accumulatedPoints(for round: Round) -> [DprTeam: Int] {
        guard let roundIndex = rounds.firstIndex(of: round)
        else { return [:] }
        return [DprTeam: Int](
            rounds[...roundIndex].flatMap(\.scores).map { score -> (DprTeam, Int) in
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

    private var addRoundButton: some View {
        HStack {
            Button(action: addRound) {
                Text(Image(systemName: "plus"))
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.purple.clipShape(Circle()))
            }
            .buttonStyle(PlainButtonStyle())
            .accessibility(label: Text("Add a new round"))
        }
    }

    private var doneButton: some View {
        HStack {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Text(Image(systemName: "checkmark"))
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.blue.clipShape(Circle()))
            }
            .buttonStyle(PlainButtonStyle())
            .accessibility(label: Text("Add a new round"))
            Spacer()
        }
    }
}

struct HeaderView: View {
    @Binding var round: Round

    var body: some View {
        NavigationLink(destination: RoundView(round: $round)) {
            HStack {
                Text(round.name)
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.heavy)
                Spacer()
                Text(Image(systemName: "highlighter"))
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.heavy)
            }
        }
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.purple.opacity(80/100))
    }
}

#if DEBUG
struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Preview()
            ScoreboardView(rounds: [])
        }
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
