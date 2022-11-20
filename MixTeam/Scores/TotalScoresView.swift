import ComposableArchitecture
import SwiftUI

struct TotalScoresView: View {
    let store: StoreOf<Scores>

    var body: some View {
        WithViewStore(store) { viewStore in
            Section(header: Text("Total")) {
                ForEach(viewStore.teams) { team in
                    HStack {
                        team.image.image
                            .resizable()
                            .frame(maxWidth: 24, maxHeight: 24)
                        Text("\(team.name)")
                        Spacer()
                        Text(viewStore.state.total(for: team))
                    }
                    .font(.body.bold())
                    .backgroundAndForeground(color: team.color)
                    .listRowSeparator(.hidden)
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
                .filter { $0.team == team }
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
