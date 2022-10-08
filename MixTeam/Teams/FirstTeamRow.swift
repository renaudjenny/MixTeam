import ComposableArchitecture
import SwiftUI

struct FirstTeamRow: View {
    let team: Team
    let store: StoreOf<App>

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
            ForEach(team.players) { player in
                PlayerRow(
                    player: player,
                    isInFirstTeam: true,
                    store: store
                )
            }
            addPlayerButton
        }
        .frame(maxWidth: .infinity)
        .background(team.colorIdentifier.color)
        .modifier(AddDashedCardStyle())
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.bottom)
    }

    private var header: some View {
        VStack {
            Text(team.name)
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
                FirstTeamRow(
                    team: Team(
                        name: "Players standing for a team with a too long text"),
                    store: .preview
                )
                FirstTeamRow(
                    team: Team(
                        name: "With right to left"),
                    store: .preview
                ).environment(\.layoutDirection, .rightToLeft)
                TeamRow(
                    team: Team(
                        name: "Test",
                        colorIdentifier: .red,
                        imageIdentifier: .koala
                    ),
                    store: .preview
                )
            }
        }
    }
}
#endif
