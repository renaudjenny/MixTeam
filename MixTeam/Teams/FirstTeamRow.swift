import SwiftUI

// TODO: fix many code duplications with TeamRow
struct FirstTeamRow: View {
    let team: Team
    let callbacks: TeamRow.Callbacks

    var body: some View {
        VStack {
            sectionHeader
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
        .modifier(AddDashedCardStyle(notchSize: CGSize(width: 50, height: 50)))
        .frame(maxWidth: .infinity)
        .padding()
    }

    // TODO: fix code duplication with TeamRow
    private var sectionHeader: some View {
        VStack {
            Text(team.name).padding(.horizontal, 50)
            team.imageIdentifier.image
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(team.colorIdentifier.color)
                .frame(width: 50, height: 50)
                .padding()
                .background(Color.white.clipShape(Circle()))
                .padding(.bottom)
        }
    }

    private var addPlayerButton: some View {
        Button(action: callbacks.createPlayer) {
            Image(systemName: "plus")
                .frame(width: 50, height: 50)
                .background(Color.white.clipShape(Circle()))
                .foregroundColor(.gray)
                .accessibility(label: Text("Add Player"))
        }.padding()
    }

    // TODO: fix code duplication with TeamRow
    private var playerRowCallbacks: PlayerRow.Callbacks {
        .init(
            edit: callbacks.editPlayer,
            delete: callbacks.deletePlayer,
            moveBack: callbacks.moveBackPlayer
        )
    }
}

struct FirstTeamRow_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View, TeamRowPreview {
        var body: some View {
            VStack {
                FirstTeamRow(team: Team(name: "Players standing for a team with a too long text"), callbacks: debuggableCallbacks)
                TeamRow(team: Team(name: "Test", colorIdentifier: .red, imageIdentifier: .koala), isFirst: false, callbacks: debuggableCallbacks)
            }
        }
    }
}
