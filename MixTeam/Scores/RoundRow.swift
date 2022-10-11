import ComposableArchitecture
import SwiftUI

struct RoundRow: View {
    let store: StoreOf<Round>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEachStore(store.scope(state: \.scores, action: Round.Action.score)) { store in
                ScoreRow(store: store)
            }
        }
        .listRowInsets(EdgeInsets())
    }
}

#if DEBUG
struct RoundRow_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        let round: Round.State = {
            guard let id = UUID(uuidString: "09756F5B-C236-41FD-B46D-991544F1698A")
            else { fatalError("Cannot generate UUID from a defined UUID String") }

            return Round.State(
                id: id,
                name: "Test Round",
                scores: [
                    Score.State(team: App.State.example.teams[1], points: 15, accumulatedPoints: 15),
                    Score.State(team: App.State.example.teams[2], points: 20, accumulatedPoints: 50),
                    Score.State(team: App.State.example.teams[3], points: 0, accumulatedPoints: 0),
                ]
            )
        }()

        var body: some View {
            let store = Store(initialState: round, reducer: Round())
            NavigationView {
                List {
                    ForEach(0..<3) { _ in
                        Section(header: HeaderView(store: store)) {
                            RoundRow(store: store)
                        }
                    }
                    .listRowBackground(Color.purple.opacity(20/100))
                }
                .navigationTitle(Text("Round row preview"))
            }
        }
    }
}
#endif
