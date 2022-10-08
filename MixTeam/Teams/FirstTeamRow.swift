import ComposableArchitecture
import SwiftUI

struct FirstTeamRow: View {
    let store: StoreOf<Team>

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
                ForEachStore(store.scope(state: \.players, action: Team.Action.player), content: PlayerRow.init)
                addPlayerButton
            }
            .frame(maxWidth: .infinity)
            .background(viewStore.colorIdentifier.color)
            .modifier(AddDashedCardStyle())
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private var header: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(viewStore.name)
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
                FirstTeamRow(store: .firstRowPreview)
                FirstTeamRow(store: .firstRowPreview).environment(\.layoutDirection, .rightToLeft)
                TeamRow(store: .preview)
            }
        }
    }
}
#endif
