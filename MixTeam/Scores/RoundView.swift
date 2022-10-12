import ComposableArchitecture
import SwiftUI

struct RoundView: View {
    let store: StoreOf<Round>

    var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Section(header: Text("Name")) {
                    TextField(
                        "Name for this round",
                        text: viewStore.binding(get: { $0.name }, send: { .nameUpdated($0) })
                    )
                }

                ForEachStore(store.scope(state: \.scores, action: Round.Action.score)) { store in
                    WithViewStore(store) { viewStore in
                        Section(header: Text(viewStore.team.name)) {
                            TextField(
                                "Score for this team",
                                text: viewStore.binding(get: { $0.points }, send: { .pointsUpdated($0) }).string
                            )
                        }
                    }
                }
            }
            .navigationTitle(Text(viewStore.name))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    WithViewStore(store) { viewStore in
                        Button { viewStore.send(.restoreBackup) } label: {
                            Text("Reset")
                        }
                    }
                }
            }
            .task { viewStore.send(.start) }
        }
    }
}

#if DEBUG
struct NewScoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoundView(store: .preview)
        }
    }
}

extension Store where State == Round.State, Action == Round.Action {
    static var preview: Self {
        Self(initialState: .preview, reducer: Round())
    }
}

extension Round.State {
    static var preview: Self {
        guard let id = UUID(uuidString: "881B7BC5-1BA6-4DDB-9C60-ACCDC4D87762")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        return Round.State(
            id: id,
            name: "Round 1",
            scores: [
            Score.State(team: App.State.example.teams[2], points: 15, accumulatedPoints: 15),
        ])
    }
}
#endif
