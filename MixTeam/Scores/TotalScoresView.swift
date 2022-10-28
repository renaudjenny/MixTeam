import ComposableArchitecture
import SwiftUI

struct TotalScoresView: View {
    let store: StoreOf<Scores>
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        WithViewStore(store) { viewStore in
            Section(header: Text("Total")) {
                ForEach(viewStore.teams) { team in
                    HStack {
                        team.imageIdentifier.image
                            .resizable()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(maxWidth: 24, maxHeight: 24)
                        Text("\(team.name)")
                        Spacer()
                        Text(viewStore.state.total(for: team))
                    }
                    .font(.body.bold())
                    .listRowBackground(team.colorIdentifier.color.opacity(30/100))
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
