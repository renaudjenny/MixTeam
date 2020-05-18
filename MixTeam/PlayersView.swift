import SwiftUI

struct PlayersView: View {
    let teams: [Team]

    var body: some View {
        List {
            ForEach(teams, content: teamRow)
        }.listStyle(GroupedListStyle())
    }

    private func teamRow(_ team: Team) -> some View {
        Section(header: sectionHeader(team: team)) {
            ForEach(team.players, content: { self.playerRow($0, team: team) })
        }
    }

    private func sectionHeader(team: Team) -> some View {
        HStack {
            team.image?.imageIdentifier.image
                .resizable()
                .frame(width: 50, height: 50)
                .padding([.leading, .top, .bottom])
            Text(team.name)
                .font(.headline)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .listRowInsets(EdgeInsets())
        .background(
            Color(team.color.color.withAlphaComponent(0.20))
        )
    }

    private func playerRow(_ player: Player, team: Team) -> some View {
        HStack {
            player.appImage?.imageIdentifier.image
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.leading, 40)
                .padding(.trailing)
            Text(player.name)
            Spacer()
        }
        .padding([.top, .bottom], 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowInsets(EdgeInsets())
        .background(
            Color(team.color.color.withAlphaComponent(0.10))
        )
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView(teams: teams)
    }

    private static let teams: [Team] = {
        let playersStandingTeam = Team(name: NSLocalizedString("Players standing for a team", comment: ""), color: .gray)
        playersStandingTeam.players = [
            Player(name: "Lara", image: .laraCraft),
            Player(name: "Harry", image: .harryPottar)
        ]
        let koalaTeam = Team(name: "Red Koala", color: .red, image: .koala)
        koalaTeam.players = [Player(name: "Vador", image: .darkVadir)]
        return [
            playersStandingTeam,
            koalaTeam,
            Team(name: "Purple Elephant", color: .purple, image: .elephant)
        ]
    }()
}

class PlayersHostingController: UIHostingController<PlayersView> {
    required init?(coder aDecoder: NSCoder) {
        let teams = Team.loadList()
        teams.first?.name = NSLocalizedString("Players standing for a team", comment: "")
        teams.first?.color = .gray
        super.init(coder: aDecoder, rootView: PlayersView(teams: teams))
    }
}
