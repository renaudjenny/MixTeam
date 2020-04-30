import SwiftUI

struct PlayersView: View {
    @ObservedObject var viewModel = PlayersViewModel()

    var body: some View {
        List {
            ForEach(viewModel.teams, content: teamRow)
        }
    }

    private func teamRow(_ team: Team) -> some View {
        Section(header: sectionHeader(team: team)) {
            ForEach(team.players, content: playerRow)
        }
    }

    private func sectionHeader(team: Team) -> some View {
        HStack {
            team.image?.imageIdentifier.image
                .resizable()
                .frame(width: 40, height: 40)
                .padding()
            Text(team.name)
        }
    }

    private func playerRow(_ player: Player) -> some View {
        Text(player.name)
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView()
    }
}

final class PlayersViewModel: ObservableObject {
    @Published var teams: [Team] = []

    init() {
        teams = Team.loadList()
    }
}
