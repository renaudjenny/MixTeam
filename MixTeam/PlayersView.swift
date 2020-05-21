import SwiftUI

struct PlayersView: View {
    let teams: [Team]
    @State var presentedAlert: PresentedAlert? = nil

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(teams, content: teamRow)
            }
            .listStyle(GroupedListStyle())
            Button(action: mixTeam) {
                Text("Mix Team")
            }
            .buttonStyle(MixTeamButtonStyle())
            .frame(height: 50)
            .shadow(radius: 10)
        }.alert(item: $presentedAlert, content: alert(for:))
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

    private func mixTeam() {
        guard self.teams.count > 2 else {
            presentedAlert = .notEnoughTeams
            return
        }

        randomizeTeam()
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

// TODO: Old code. Refactor and simplify this
extension PlayersView {
    private func randomizeTeam() {
        // Move all players to standing state
        let playersStanding = teams
            .filter { $0 != teams.first }
            .map(\.players)
            .flatMap { $0 }

        var teamsHandicap: [Team: Int] = Dictionary(teams
            .map({ team -> (Team, Int) in
                let handicapSum = team.players
                    .map(\.handicap)
                    .reduce(0, +)
                return (team, handicapSum)
            }), uniquingKeysWith: { $1 })

        let playersTotalHandicap = teamsHandicap.values.reduce(0, +)

        for team in teams {
            for player in team.players {
                let toTeam = pseudoRandomTeam(teamsHandicap: teamsHandicap, playersTotalHandicap: playersTotalHandicap)
                teamsHandicap[team]! -= player.handicap
                teamsHandicap[toTeam]! += player.handicap
                if team != toTeam {
                    self.move(player: player, from: team, to: toTeam)
                }
            }
        }
    }

    private func move(player: Player, from fromTeam: Team, to toTeam: Team) {
        guard let originPlayerIndex = fromTeam.players.firstIndex(where: { $0.id == player.id }) else {
            return
        }

        toTeam.players.append(player)
        fromTeam.players.remove(at: originPlayerIndex)

        // deferAutoSave()
    }

    private func pseudoRandomTeam(teamsHandicap: [Team: Int], playersTotalHandicap: Int) -> Team {
        // First, add a player in each team if there is no one yet
        let teamsWithoutPlayers = self.teams
            .filter { $0 != self.teams.first }
            .filter { teamsHandicap[$0]! <= 0 }

        if teamsWithoutPlayers.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(teamsWithoutPlayers.count)))
            return teamsWithoutPlayers[randomIndex]
        }

        let handicapAverage = playersTotalHandicap / (self.teams.count - 1)

        // Choose only teams that total handicap is under the average
        let unbalancedTeams = self.teams
            .filter { $0 != self.teams.first }
            .filter { teamsHandicap[$0]! < handicapAverage }

        let randomIndex = Int.random(in: 0..<unbalancedTeams.count)
        return unbalancedTeams[randomIndex]
    }

    private func remove(team: Team) {
        guard let firstTeam = self.teams.first,
            let teamToDeleteIndex = self.teams.firstIndex(where: { $0 == team }) else {
                fatalError("Cannot retrieve first team or team to delete index")
        }

        let teamToDelete = self.teams[teamToDeleteIndex]

        teamToDelete.players.forEach { (player) in
            self.move(player: player, from: teamToDelete, to: firstTeam)
        }

        // TODO: Teams need to be a binding/state
        // teams.remove(at: teamToDeleteIndex)
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
