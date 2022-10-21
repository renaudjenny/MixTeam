import ComposableArchitecture
import SwiftUI

struct ScoreboardView: View {
    let store: StoreOf<Scores>
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    if viewStore.rounds.count > 0 {
                        list
                    } else {
                        VStack {
                            Text("Add your first round by tapping on the plus button")
                                .foregroundColor(.gray)
                            Button { viewStore.send(.addRound) } label: {
                                Label("Add a new round", systemImage: "plus")
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle(Text("Scoreboard"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { viewStore.send(.addRound, animation: .default) } label: {
                            Label("Add a new round", systemImage: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { presentationMode.wrappedValue.dismiss() } label: {
                            Label("Done", systemImage: "checkmark")
                        }
                    }
                }
            }
        }
    }

    private var list: some View {
        List {
            ForEachStore(store.scope(state: \.rounds, action: Scores.Action.round)) { store in
                WithViewStore(store) { viewStore in
                    Section(header: Text(viewStore.name)) {
                        NavigationLink(destination: RoundView(store: store)) {
                            VStack {
                                ForEachStore(store.scope(state: \.scores, action: Round.Action.score)) { store in
                                    ScoreRow(store: store)
                                }
                            }
                        }
                        .swipeActions {
                            Button(
                                role: .destructive,
                                action: { viewStore.send(.remove, animation: .default) },
                                label: { Label("Delete", systemImage: "trash") }
                            )
                        }
                    }
                }
            }

            TotalScoresView(store: store)
        }
    }
}

#if DEBUG
struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView(store: .preview)
        ScoreboardView(store: .previewWithScores)
    }
}

extension Store where State == Scores.State, Action == Scores.Action {
    static var preview: Self {
        Self(initialState: .preview, reducer: Scores())
    }
    static var previewWithScores: Self {
        Self(initialState: .previewWithScores, reducer: Scores())
    }
}

extension Scores.State {
    static var preview: Self {
        Scores.State(teams: App.State.example.teams)
    }
    static var previewWithScores: Self {
        guard let round1ID = UUID(uuidString: "3B9523DF-6CE6-4561-8B4A-003BD57BC22A"),
              let round2ID = UUID(uuidString: "3891A3AB-0E2A-4874-AAB0-8228EB38E983"),
              let round3ID = UUID(uuidString: "00BAAAA0-33FE-43F2-BC46-29735A013953"),
              let round4ID = UUID(uuidString: "1F398B53-9F5E-486F-8C57-705E5659EADA"),
              let round5ID = UUID(uuidString: "723994B2-4CC4-4BAD-A31E-22E5120A4D36")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        let teams = App.State.example.teams
        return Scores.State(teams: teams, rounds: [
            Round.State(
                id: round1ID,
                name: "Round 1",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(team: $0, points: 10, accumulatedPoints: 10)
                })
            ),
            Round.State(
                id: round2ID,
                name: "Round 2",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(team: $0, points: 10, accumulatedPoints: 20)
                })
            ),
            Round.State(
                id: round3ID,
                name: "Round 3",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(team: $0, points: 10, accumulatedPoints: 30)
                })
            ),
            Round.State(
                id: round4ID,
                name: "Round 4",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(team: $0, points: 10, accumulatedPoints: 40)
                })
            ),
            Round.State(
                id: round5ID,
                name: "Round 5",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(team: $0, points: 10, accumulatedPoints: 50)
                })
            ),
        ])
    }
}
#endif
