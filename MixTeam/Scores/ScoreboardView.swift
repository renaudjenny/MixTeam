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
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Button { viewStore.send(.minusScore(score: focusedField)) } label: {
                                        Label("Positive/Negative", systemImage: "plus.forwardslash.minus")
                                    }

                                    Button { focusedField = nil } label: {
                                        Label("Done", systemImage: "checkmark")
                                    }
                                }
                            }
                    } else {
                        VStack {
                            Text("Add your first round by tapping on the plus button")
                            Button { viewStore.send(.addRound) } label: {
                                Label("Add a new round", systemImage: "plus")
                                    .labelStyle(.iconOnly)
                            }
                            .padding()
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
            .backgroundAndForeground(color: .aluminium)
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
        ScoreboardView(store: .previewWithManyScores)
    }
}

extension Store where State == Scores.State, Action == Scores.Action {
    static var preview: Self {
        Self(initialState: .preview, reducer: Scores())
    }
    static var previewWithScores: Self {
        Self(initialState: .previewWithScores(count: 5), reducer: Scores())
    }
    static var previewWithManyScores: Self {
        Self(initialState: .previewWithScores(count: 300), reducer: Scores())
    }
}

extension Scores.State {
    static var preview: Self {
        Scores.State(teams: App.State.example.teams)
    }
    static func previewWithScores(count: Int) -> Self {
        let teams = App.State.example.teams
        let uuid = UUIDGenerator.incrementing
        return Scores.State(teams: teams, rounds: IdentifiedArrayOf(uniqueElements: (1...count).map { i in
            Round.State(
                id: uuid(),
                name: "Round \(i)",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(id: uuid(), team: $0, points: 10 * i, accumulatedPoints: 10 * i + 10 * (i - 1))
                }))
        }))
    }
}
#endif
