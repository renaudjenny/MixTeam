import ComposableArchitecture
import SwiftUI

struct StandingView: View {
    let store: StoreOf<Standing>

    var body: some View {
        ZStack(alignment: .topTrailing) {
            card
        }
    }

    var card: some View {
        VStack {
            header
                .font(.callout)
                .foregroundColor(Color.white)
                .padding(.top)
            ForEachStore(store.scope(state: \.players, action: Standing.Action.player), content: PlayerRow.init)
            addPlayerButton
        }
        .frame(maxWidth: .infinity)
        .background(.gray)
        .modifier(AddDashedCardStyle())
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.bottom)
    }

    private var header: some View {
        VStack {
            Text("Players standing for a team")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            Image(systemName: "person.3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
        }
    }

    private var addPlayerButton: some View {
        WithViewStore(store.stateless) { ViewStore in
            Button { ViewStore.send(.createPlayer, animation: .easeInOut) } label: {
                Image(systemName: "plus")
                    .frame(width: 50, height: 50)
                    .background(Color.white.clipShape(Splash2()))
                    .foregroundColor(.gray)
                    .accessibility(label: Text("Add Player"))
            }.padding()
        }
    }
}

#if DEBUG
struct FirstTeamRow_Previews: PreviewProvider {
    static var previews: some View {
        StandingView(store: .preview)
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
