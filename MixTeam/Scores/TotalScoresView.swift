import ComposableArchitecture
import SwiftUI

struct TotalScoresView: View {
    let store: StoreOf<Scores>

    var body: some View {
        WithViewStore(store) { viewStore in
            Section(header: header) {
                ForEach(viewStore.teams) { team in
                    HStack {
                        Text("\(team.name)")
                        Spacer()
                        ZStack {
                            Text("99999").hidden()
                            Text(viewStore.state.total(for: team))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        .background(Color.purple.clipShape(Ellipse()))
                    }
                }
                .listRowBackground(Color.purple.opacity(20/100))
            }
        }
    }

    private var header: some View {
        HStack {
        Text("Total")
            .font(.title3)
            .fontWeight(.heavy)
            .foregroundColor(.white)
            Spacer()
        }
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.purple)
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
