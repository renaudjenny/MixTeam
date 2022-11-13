import ComposableArchitecture
import SwiftUI

struct StandingView: View {
    let store: StoreOf<Standing>
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Section {
            header
            ForEachStore(store.scope(state: \.players, action: Standing.Action.player), content: PlayerRow.init)
        }
    }

    private var header: some View {
        WithViewStore(store.stateless) { ViewStore in
            VStack {
                Text("Players standing for a team")
                    .font(.title3)
                    .fontWeight(.semibold)
                Button { ViewStore.send(.createPlayer, animation: .easeInOut) } label: {
                    Label { Text("Add Player") } icon: {
                        HStack {
                            Image(systemName: "person.3")
                            Image(systemName: "plus")
                        }
                        .font(.title3)
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(DashedButtonStyle(color: .gray))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .listRowBackground(Color.gray)
        }
    }
}

#if DEBUG
struct FirstTeamRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            StandingView(store: .preview)
        }
        .listStyle(.plain)
    }
}

extension Store where State == Standing.State, Action == Standing.Action {
    static var preview: Self {
        Self(initialState: .preview, reducer: Standing())
    }
}

private extension Standing.State {
    static var preview: Self {
        Standing.State(
            players: [Player.State(id: UUID(), name: "Player 1", image: .girl, isStanding: true, color: .gray)]
        )
    }
}
#endif
