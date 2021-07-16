import SwiftUI

struct FirstTeamRow: View {
    let team: Team
    let callbacks: FirstTeamRow.Callbacks

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
                    callbacks: self.playerRowCallbacks
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
        Button(action: callbacks.createPlayer) {
            Image(systemName: "plus")
                .frame(width: 50, height: 50)
                .background(Color.white.clipShape(Splash2()))
                .foregroundColor(.gray)
                .accessibility(label: Text("Add Player"))
        }.padding()
    }
}

// MARK: Player Row Callbacks
extension FirstTeamRow {
    struct Callbacks {
        let createPlayer: () -> Void
        let editPlayer: (Player) -> Void
        let deletePlayer: (Player) -> Void
    }

    private var playerRowCallbacks: PlayerRow.Callbacks {
        .init(
            edit: callbacks.editPlayer,
            delete: callbacks.deletePlayer,
            moveBack: { _ in }
        )
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

    private struct Preview: View, TeamRowPreview {
        var body: some View {
            ScrollView {
                FirstTeamRow(
                    team: Team(
                        name: "Players standing for a team with a too long text"),
                    callbacks: firstTeamDebuggableCallbacks
                )
                FirstTeamRow(
                    team: Team(
                        name: "With right to left"),
                    callbacks: firstTeamDebuggableCallbacks
                ).environment(\.layoutDirection, .rightToLeft)
                TeamRow(
                    team: Team(
                        name: "Test",
                        colorIdentifier: .red,
                        imageIdentifier: .koala
                    ),
                    callbacks: debuggableCallbacks
                )
            }
        }
    }
}
#endif
