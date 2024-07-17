import ComposableArchitecture
import SwiftUI
import TeamsFeature

struct ScoresView: View {
    @Bindable var store: StoreOf<Scores>
    @FocusState private var focusedField: Score.State?
    @FocusState private var focusedHeader: Round.State?

    var body: some View {
        NavigationView {
            ZStack {
                if store.rounds.count > 0 {
                    list
                        .bind($store.focusedField, to: $focusedField)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                if focusedHeader == nil {
                                    Button { store.send(.minusScore(score: focusedField)) } label: {
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
                        Button { store.send(.addRound) } label: {
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
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { store.send(.addRound, animation: .default) } label: {
                        Label("Add a new round", systemImage: "plus")
                    }
                }
                #else
                ToolbarItem() {
                    Button { store.send(.addRound, animation: .default) } label: {
                        Label("Add a new round", systemImage: "plus")
                    }
                }
                #endif
            }
        }
        .backgroundAndForeground(color: .aluminium)
        .task { store.send(.task) }
    }

    private var list: some View {
        List {
            ForEachStore(store.scope(state: \.rounds, action: \.rounds)) { store in
                RoundView(store: store, focusedField: _focusedField, focusedHeader: _focusedHeader)
            }
            TotalScoresView(store: store)
        }
    }
}

extension Score.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#if DEBUG
struct ScoresView_Previews: PreviewProvider {
    static var previews: some View {
        ScoresView(store: .preview)
        ScoresView(store: .previewWithScores)
        ScoresView(store: .previewWithManyScores)
    }
}

extension Store where State == Scores.State, Action == Scores.Action {
    static var preview: Self {
        Self(initialState: .preview) { Scores() }
    }
    static var previewWithScores: Self {
        Self(initialState: .previewWithScores(count: 5)) { Scores() }
    }
    static var previewWithManyScores: Self {
        Self(initialState: .previewWithScores(count: 300)) { Scores() }
    }
}

public extension Scores.State {
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
