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
        WithViewStore(store.stateless) { viewStore in
            List {
                ForEachStore(store.scope(state: \.rounds, action: Scores.Action.round)) { store in
                    VStack {
                        HeaderView(store: store)
                            .padding(.vertical, 4)
                        ForEachStore(store.scope(state: \.scores, action: Round.Action.score)) { store in
                            ScoreRow(store: store)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { viewStore.send(.remove(atOffsets: $0), animation: .default) }

                TotalScoresView(store: store)
            }
            .listStyle(.plain)
        }
    }
}

struct HeaderView: View {
    let store: StoreOf<Round>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationLink(destination: RoundView(store: store)) {
                HStack {
                    Text(viewStore.name)
                        .font(.title2)
                    Spacer()
                    Label("Edit", systemImage: "highlighter")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                }
            }
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
        guard let roundID = UUID(uuidString: "3B9523DF-6CE6-4561-8B4A-003BD57BC22A")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        let teams = App.State.example.teams
        return Scores.State(teams: teams, rounds: [
            Round.State(
                id: roundID,
                name: "Round 1",
                scores: IdentifiedArrayOf(uniqueElements: teams.map {
                    Score.State(team: $0, points: 10, accumulatedPoints: 10)
                })
            ),
        ])
    }
}
#endif
