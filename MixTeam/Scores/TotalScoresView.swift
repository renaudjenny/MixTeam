import ComposableArchitecture
import SwiftUI

struct TotalScoresView: View {
    let store: StoreOf<Scores>

    var body: some View {
        WithViewStore(store) { viewStore in
            Section(header: Text("Total")) {
                ForEach(viewStore.teams) { team in
                    HStack {
                        Text("\(team.name)")
                        Spacer()
                        Text(viewStore.state.total(for: team))
                    }
                }
            }
        }
    }
}

private extension Scores.State {
    func total(for team: Team.State) -> String {
        String(
            rounds
                .flatMap(\.scores)
                .filter { $0.id == team.id }
                .map(\.points)
                .reduce(0, +)
        )
    }
}

#if DEBUG
struct TotalScoresView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TotalScoresView(store: .preview)
        }
    }
}
#endif
