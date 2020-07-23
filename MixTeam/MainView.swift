import SwiftUI

struct MainView: View {
    static let playersColorResetDelay: DispatchTimeInterval = .milliseconds(400)
    @EnvironmentObject var teamsStore: TeamsStore
    @State private var presentedAlert: PresentedAlert?
    @State private var editedTeam: Team?
    @State private var editedPlayer: Player?

    var body: some View {
        ScrollView {
            teamsStore.teams.first.map { FirstTeamRow(team: $0, callbacks: teamCallbacks) }
            mixTeamButton
            ForEach(teamsStore.teams.dropFirst(), content: teamRow)
            addTeamButton
        }
        .animation(.default)
        .frame(maxWidth: 800)
        .alert(item: $presentedAlert, content: alert(for:))
        .background(Color.clear.sheet(item: $editedTeam) {
            self.teamsStore.teams.firstIndex(of: $0).map {
                EditTeamView(team: self.$teamsStore.teams[$0])
            }
        })
        .background(Color.clear.sheet(item: $editedPlayer) { player in
            self.teamsStore.teams.firstIndex(where: { team in team.players.contains(player) }).map { teamIndex in
                self.teamsStore.teams[teamIndex].players.firstIndex(of: player).map { playerIndex in
                    EditPlayerView(
                        player: self.$teamsStore.teams[teamIndex].players[playerIndex],
                        team: self.teamsStore.teams[teamIndex]
                    )
                }
            }
        })
    }

    func teamRow(team: Team) -> some View {
        TeamRow(team: team, isFirst: false, callbacks: teamCallbacks)
            .transition(.move(edge: .leading))
    }

    private var mixTeamButton: some View {
        Button(action: mixTeam) {
            HStack {
                Image(systemName: "shuffle")
                Text("Mix Team")
            }
        }
        .buttonStyle(MixTeamButtonStyle())
        .frame(height: 50)
        .modifier(Shadow())
        .padding(.horizontal)
        .accessibility(label: Text("Mix Team"))
    }

    private var addTeamButton: some View {
        Button(action: createRandomTeam) {
            HStack {
                Image(systemName: "plus")
                Text("Add a new Team")
            }.frame(maxWidth: .infinity)
        }
        .buttonStyle(CommonButtonStyle(color: .red))
        .padding()
        .accessibility(label: Text("Add Team"))
    }
}

// MARK: MixTeam Logic
extension MainView: MixTeamLogic {
    var presentedAlertBinding: Binding<PresentedAlert?> { $presentedAlert }
}

// MARK: Teams Logic
extension MainView: TeamsLogic {
    var teamCallbacks: TeamRow.Callbacks {
        .init(
            editTeam: { self.editedTeam = $0 },
            deleteTeam: delete(team:),
            createPlayer: createRandomPlayer,
            editPlayer: { self.editedPlayer = $0 },
            moveBackPlayer: moveBack(player:),
            deletePlayer: delete(player:)
        )
    }
}

// MARK: PresentedAlert
extension MainView {
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
        Group {
            MainView()
                .environmentObject(TeamsStore())
            MainView()
                .environmentObject(TeamsStore())
                .environment(\.colorScheme, .dark)
        }
    }
}
