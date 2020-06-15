import SwiftUI
import Combine

final class PlayersViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var presentedAlert: PlayersView.PresentedAlert? = nil

    private var cancellables = Set<AnyCancellable>()

    init() {
        teams = Team.loadList()
        let firstTeam = Team(name: "Players standing for a team", colorIdentifier: .gray, imageIdentifier: .unknown)
        if teams.count <= 0 {
            teams.append(firstTeam)
        }
        teams[0] = firstTeam
        Team.save(teams: teams)
        NotificationCenter.default.publisher(for: .TeamsUpdated)
            .compactMap({ $0.object as? [Team] })
            .assign(to: \.teams, on: self)
            .store(in: &cancellables)
    }

    func mixTeam() {
        guard teams.count > 2 else {
            presentedAlert = .notEnoughTeams
            return
        }

        randomizeTeam()
    }

    func deletePlayer(in team: Team, at offsets: IndexSet) {
        guard let index = teams.firstIndex(of: team) else { return }
        teams[index].players.remove(atOffsets: offsets)
        Team.save(teams: teams)
    }

    func color(for player: Player) -> Color {
        guard let team = teams.first(where: { $0.players.contains(player) }) else {
            return .gray
        }
        return team.colorIdentifier.color
    }

    func playerBinding(for player: Player) -> Binding<Player>? {
        guard let teamIndex = teams.firstIndex(where: { $0.players.contains(player) }),
            let playerIndex = teams[teamIndex].players.firstIndex(of: player) else {
            return nil
        }
        return Binding<Player>(
            get: { self.teams[teamIndex].players[playerIndex] },
            set: { self.teams[teamIndex].players[playerIndex] = $0 }
        )
    }

    func createPlayer(name: String, image: ImageIdentifier) {
        guard var playersStandingForATeam = teams.first else { return }
        playersStandingForATeam.players.append(Player(name: name, image: image.appImage))
        teams[0] = playersStandingForATeam
        Team.save(teams: teams)
    }
}

extension PlayersViewModel {
    static let playersColorResetDelay: DispatchTimeInterval = .milliseconds(400)

    private func randomizeTeam() {
        let players = teams.flatMap(\.players)
        guard players.count > 0 else { return }
        guard teams.filter({ $0 != teams.first }).count > 1 else { return }

        teams = teams.map({
            var newTeam = $0
            newTeam.players = []
            return newTeam
        })

        teams = players.shuffled().reduce(teams) { teams, player in
            var teams = teams
            let availableTeams = teams.filter { $0 != teams.first }
            guard let lessPlayerTeam = availableTeams.sorted(by: hasLessPlayer).first,
                let teamIndex = teams.firstIndex(of: lessPlayerTeam) else { return teams }
            teams[teamIndex].players += [player]
            return teams
        }
        Team.save(teams: teams)
        delayPlayersColorReset()
    }

    private func hasLessPlayer(teamA a: Team, teamB b: Team) -> Bool {
        return a.players.count < b.players.count
    }

    private func delayPlayersColorReset() {
        // We need to delay the Player Id reset. Otherwise there will no row animations
        // on the table. And if we don't reset players id, color won't change.
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.playersColorResetDelay) { [weak self] in
            guard let self = self else { return }
            self.teams = self.teams.map({
                var team = $0
                team.players = $0.players.map { Player($0) }
                return team
            })
        }
    }
}
