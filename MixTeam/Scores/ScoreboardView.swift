import ComposableArchitecture
import SwiftUI

struct ScoreboardView: View {
    let store: StoreOf<Scores>
    @Environment(\.presentationMode) private var presentationMode
    @FocusState private var focusedField: Score.State?

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    if viewStore.rounds.count > 0 {
                        list
                            .synchronize(viewStore.binding(\.$focusedField), $focusedField)
                            .modifier(ScrollDismissesKeyboard())
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Button { viewStore.send(.minusScore(score: focusedField)) } label: {
                                        Label("Minus", systemImage: "minus.circle")
                                    }

                                    Button { focusedField = nil } label: {
                                        Label("Done", systemImage: "checkmark")
                                    }
                                }
                            }
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
                        ForEachStore(store.scope(state: \.scores, action: Round.Action.score)) { store in
                            ScoreRow(store: store, focusedField: _focusedField)
                        }
                    }
                }
            }

            TotalScoresView(store: store)
        }
    }
}

private struct ScrollDismissesKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollDismissesKeyboard(.immediately)
        } else {
            content
        }
    }
}

extension View {
    func synchronize<Value>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}

extension Score.State: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
              let round5ID = UUID(uuidString: "723994B2-4CC4-4BAD-A31E-22E5120A4D36"),
              let score1ID = UUID(uuidString: "2411540E-54BE-4176-A712-2DC702A60F1B"),
              let score2ID = UUID(uuidString: "0105D2A7-9A66-4742-9D32-769DFB0E522C"),
              let score3ID = UUID(uuidString: "0B778EB8-56ED-4830-8039-6D0972BDD473"),
              let score4ID = UUID(uuidString: "E3306CB8-CB29-46FE-873C-A23E16606CAE"),
              let score5ID = UUID(uuidString: "F33CA046-F479-4230-82F2-096A82F38A13")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        let teams = App.State.example.teams
        return Scores.State(teams: teams, rounds: [
            Round.State(
                id: round1ID,
                name: "Round 1",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(id: score1ID, team: $0, points: 10, accumulatedPoints: 10)
                })
            ),
            Round.State(
                id: round2ID,
                name: "Round 2",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(id: score2ID, team: $0, points: 10, accumulatedPoints: 20)
                })
            ),
            Round.State(
                id: round3ID,
                name: "Round 3",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(id: score3ID, team: $0, points: 10, accumulatedPoints: 30)
                })
            ),
            Round.State(
                id: round4ID,
                name: "Round 4",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(id: score4ID, team: $0, points: 10, accumulatedPoints: 40)
                })
            ),
            Round.State(
                id: round5ID,
                name: "Round 5",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(id: score5ID, team: $0, points: 10, accumulatedPoints: 50)
                })
            ),
        ])
    }
}
#endif
