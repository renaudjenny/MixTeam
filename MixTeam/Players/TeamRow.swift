import SwiftUI

struct TeamRow: View {
    let team: Team
    let isFirstTeam: Bool
    let editPlayer: (Player) -> Void
    let deletePlayer: (Player) -> Void
    let moveBackPlayer: (Player) -> Void
    let createPlayer: (String, ImageIdentifier) -> Void

    var body: some View {
        VStack {
            sectionHeader(team: team)
                .font(.callout)
                .foregroundColor(Color.white)
                .padding(.top)
            ForEach(team.players) { player in
                PlayerRow(
                    player: player,
                    isInFirstTeam: self.isFirstTeam,
                    edit: { self.editPlayer(player) },
                    delete: { self.deletePlayer(player) },
                    moveBack: { self.moveBackPlayer(player) }
                )
            }
            if isFirstTeam {
                addPlayerButton
            }
        }
        .background(team.colorIdentifier.color)
        .modifier(AddDashedCardStyle())
        .frame(maxWidth: .infinity)
        .padding()
    }

    private func sectionHeader(team: Team) -> some View {
        VStack {
            Text(team.name).padding([.leading, .trailing])
            team.imageIdentifier.image
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(team.colorIdentifier.color)
                .frame(width: 50, height: 50)
                .padding()
                .background(
                    Color.white
                        .clipShape(Circle())
            )
                .padding(.bottom)
        }.frame(maxWidth: .infinity)
    }

    private var addPlayerButton: some View {
        NavigationLink(destination: AddPlayerView(createPlayer: createPlayer), label: {
            Image(systemName: "plus")
                .frame(width: 50, height: 50)
                .background(Color.white.clipShape(Circle()))
                .foregroundColor(.gray)
                .accessibility(label: Text("Add Player"))
        }).padding()
    }
}

struct TeamRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TeamRow(
                team: Team(
                    id: UUID(),
                    name: "Team Test",
                    colorIdentifier: .red,
                    imageIdentifier: .koala,
                    players: []
                ),
                isFirstTeam: false,
                editPlayer: { _ in },
                deletePlayer: { _ in },
                moveBackPlayer: { _ in },
                createPlayer: { _, _ in }
            )
            TeamRow(
                team: Team(
                    id: UUID(),
                    name: "Team Test with Players",
                    colorIdentifier: .blue,
                    imageIdentifier: .octopus,
                    players: [
                        Player(name: "Player 1", imageIdentifier: .harryPottar),
                        Player(name: "Player 2", imageIdentifier: .theBotman)
                    ]
                ),
                isFirstTeam: false,
                editPlayer: { _ in },
                deletePlayer: { _ in },
                moveBackPlayer: { _ in },
                createPlayer: { _, _ in }
            )
            TeamRow(
                team: Team(
                    id: UUID(),
                    name: "Players standing for a Team",
                    colorIdentifier: .gray,
                    imageIdentifier: .unknown,
                    players: [
                        Player(name: "Player 1", imageIdentifier: .harryPottar)
                    ]
                ),
                isFirstTeam: true,
                editPlayer: { _ in },
                deletePlayer: { _ in },
                moveBackPlayer: { _ in },
                createPlayer: { _, _ in }
            )
        }
    }
}
