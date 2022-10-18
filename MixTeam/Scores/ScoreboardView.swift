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
            }
        }
    }

    private var list: some View {
        WithViewStore(store.stateless) { viewStore in
            List {
                ForEachStore(store.scope(state: \.rounds, action: Scores.Action.round)) { store in
                    Section(header: HeaderView(store: store)) {
                        RoundRow(store: store)
                    }
                }
                .onDelete { viewStore.send(.remove(atOffsets: $0)) }
                .listRowBackground(Color.purple.opacity(20/100))

                TotalScoresView(store: store)
            }
            .listStyle(.plain)
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
    let store: StoreOf<Round>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationLink(destination: RoundView(store: store)) {
                HStack {
                    Text(viewStore.name)
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
