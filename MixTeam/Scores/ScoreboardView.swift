import ComposableArchitecture
import SwiftUI
import SwiftUINavigation

struct ScoreboardView: View {
    let store: StoreOf<Scores>
    @Environment(\.presentationMode) private var presentationMode
    @FocusState private var focusedField: Score.State?
    @FocusState private var focusedHeader: Round.State?

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    if viewStore.rounds.count > 0 {
                        list
                            .bind(viewStore.binding(\.$focusedField), to: $focusedField)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    if focusedHeader == nil {
                                        Button { viewStore.send(.minusScore(score: focusedField)) } label: {
                                            Label("Positive/Negative", systemImage: "plus.forwardslash.minus")
                                        }

                                        Button {
                                            focusedField = nil
                                            focusedHeader = nil
                                        } label: {
                                            Label("Done", systemImage: "checkmark")
                                        }
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
            .task { viewStore.send(.task) }
        }
    }

    private var list: some View {
        List {
            ForEachStore(store.scope(state: \.rounds, action: Scores.Action.round)) { store in
                WithViewStore(store) { viewStore in
                    Section(
                        header: TextField("Round name", text: viewStore.binding(\.$name))
                            .focused($focusedHeader, equals: viewStore.state)
                    ) {
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
        Self(teams: .example)
    }
    static func previewWithScores(count: Int) -> Self {
        let teams: IdentifiedArrayOf<Team.State> = .example
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
