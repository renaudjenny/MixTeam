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
        WithViewStore(store) { viewStore in
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
    }

    private var header: some View {
        WithViewStore(store) { viewStore in
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
    }

    private var addPlayerButton: some View {
        WithViewStore(store.stateless) { ViewStore in
            Button { ViewStore.send(.createPlayer) } label: {
                Image(systemName: "plus")
                    .frame(width: 50, height: 50)
                    .background(Color.white.clipShape(Splash2()))
                    .foregroundColor(.gray)
                    .accessibility(label: Text("Add Player"))
            }.padding()
        }
    }
}

private extension CGSize {
    static func + (lhs: Self, rhs: CGFloat) -> Self {
        CGSize(width: lhs.width + rhs, height: lhs.height + rhs)
    }
}

#if DEBUG
struct FirstTeamRow_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        var body: some View {
            ScrollView {
                StandingView(store: .preview)
                StandingView(store: .preview).environment(\.layoutDirection, .rightToLeft)
                TeamRow(store: .preview)
            }
        }
    }
}

extension StoreOf<Standing> {
    static var preview: StoreOf<Standing> {
        Store(
            initialState: Standing.State(players: [Player.State(id: UUID(), name: "Player 1", image: .girl)]),
            reducer: Standing()
        )
    }
}
#endif
