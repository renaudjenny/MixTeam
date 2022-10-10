import ComposableArchitecture
import SwiftUI

struct ScoreboardView: View {
    let store: StoreOf<Scores>
    @AppStorage("Scores.rounds") var rounds: Rounds = []
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
                Section(header: HeaderView(store: store, round: round)) {
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

    private func addRound(teams: [Team.State]) {
        let scores = teams.map { team in Round.Score(team: team, points: 0) }
        rounds.append(Round(name: "Round \(rounds.count + 1)", scores: scores))
        isNavigateToNewRoundActive = true
    }

    private func accumulatedPoints(for round: Round) -> [Team.State: Int] {
        guard let roundIndex = rounds.firstIndex(of: round)
        else { return [:] }
        return [Team.State: Int](
            rounds[...roundIndex].flatMap(\.scores).map { score -> (Team.State, Int) in
                (score.team, score.points)
            },
            uniquingKeysWith: { $0 + $1 }
        )
    }

    @ViewBuilder
    private func navigationToNew() -> some View {
        if rounds.count > 0 {
            NavigationLink(
                destination: RoundView(store: store, round: $rounds[rounds.count - 1]),
                isActive: $isNavigateToNewRoundActive,
                label: EmptyView.init
            )
        }
    }

    private var addRoundButton: some View {
        WithViewStore(store.stateless) { viewStore in
            HStack {
                Button { viewStore.send(.addRound) } label: {
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
    let store: StoreOf<Scores>
    @Binding var round: Round

    var body: some View {
        NavigationLink(destination: RoundView(store: store, round: $round)) {
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
            ScoreboardView(store: .preview, rounds: [])
        }
    }

    private struct Preview: View {
        @AppStorage("Scores.rounds") var rounds: Rounds = []

        var body: some View {
            VStack {
                ScoreboardView(store: .preview, rounds: .mock)
                Button("Reset App Storage") {
                    rounds = .mock
                }
                .accentColor(.red)
            }
        }
    }
}

extension StoreOf<Scores> {
    static var preview: StoreOf<Scores> {
        Store(initialState: .preview, reducer: Scores())
    }
}

extension Scores.State {
    static var preview: Self {
        Scores.State(teams: App.State.example.teams)
    }
}
#endif
