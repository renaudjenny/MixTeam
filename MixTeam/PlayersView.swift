import SwiftUI

struct PlayersView: View {
    @ObservedObject var viewModel = PlayersViewModel()

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(viewModel.teams, content: teamRow)
            }
            .listStyle(GroupedListStyle())
            Button(action: viewModel.mixTeam) {
                Text("Mix Team")
            }
            .buttonStyle(MixTeamButtonStyle())
            .frame(height: 50)
            .shadow(radius: 10)
        }.alert(item: $viewModel.presentedAlert, content: alert(for:))
    }

    private func teamRow(_ team: Team) -> some View {
        Section(header: sectionHeader(team: team)) {
            ForEach(team.players, content: self.playerRow)
                .onDelete(perform: { self.viewModel.deletePlayer(in: team, at: $0) })
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

    private func playerRow(_ player: Player) -> some View {
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
            viewModel.color(for: player).opacity(0.10)
        )
    }
}

extension PlayersView {
    enum PresentedAlert: Identifiable {
        case notEnoughTeams

        var id: Int { self.hashValue }
    }

    private func alert(for identifier: PresentedAlert) -> Alert {
        Alert(title: Text("Couldn't Mix Team with less than 2 teams. Go create some teams :)"))
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView()
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
        super.init(coder: aDecoder, rootView: PlayersView())
    }
}
