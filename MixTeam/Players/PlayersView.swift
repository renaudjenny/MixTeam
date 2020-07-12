import SwiftUI

struct PlayersView: View {
    static let playersColorResetDelay: DispatchTimeInterval = .milliseconds(400)
    static let shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.25)
    @EnvironmentObject var teamsStore: TeamsStore
    @State private var editedTeam: Team?
    @State private var editedPlayer: Player?
    @State private var presentedAlert: PresentedAlert?

    var body: some View {
        NavigationView {
            playersView
        }
    }

    private var playersView: some View {
        ScrollView {
            TeamRow(
                team: teams.first ?? Team(),
                isFirstTeam: true,
                editPlayer: { self.editedPlayer = $0 },
                deletePlayer: deletePlayer,
                moveBackPlayer: moveBack,
                createPlayer: createPlayer,
                editTeam: { _ in },
                deleteTeam: deleteTeam
            )
            mixTeamButton
            ForEach(teams.dropFirst(), content: teamRow)
            addTeamButton
        }
        .animation(.default)
        .alert(item: $presentedAlert, content: alert(for:))
        .background(EmptyView().sheet(item: $editedPlayer, content: edit(player:)))
        .background(EmptyView().sheet(item: $editedTeam, content: edit(team:)))
        .navigationBarTitle("Players")
    }

    func teamRow(_ team: Team) -> some View {
        TeamRow(
            team: team,
            isFirstTeam: false,
            editPlayer: { self.editedPlayer = $0 },
            deletePlayer: deletePlayer,
            moveBackPlayer: moveBack,
            createPlayer: createPlayer,
            editTeam: { self.editedTeam = $0 },
            deleteTeam: deleteTeam
        )
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
        .shadow(
            color: Self.shadowColor,
            radius: 3, x: -2, y: 2
        )
        .padding([.leading, .trailing])
        .accessibility(label: Text("Mix Team"))
    }

    private var addTeamButton: some View {
        NavigationLink(destination: AddTeamView(createTeam: createTeam), label: {
            HStack {
                Image(systemName: "plus")
                Text("Add a new Team")
            }.frame(maxWidth: .infinity)
        })
            .foregroundColor(Color.white)
            .frame(height: 50)
            .background(Color.red)
            .modifier(AddDashedCardStyle())
            .padding()
            .accessibility(label: Text("Add Team"))
    }
}

// MARK: Players Logic
extension PlayersView: PlayersLogic {
    private func edit(player: Player) -> some View {
        EditPlayerView(player: player, editPlayer: editPlayer)
    }
}

// MARK: MixTeam Logic
extension PlayersView: MixTeamLogic {
    var presentedAlertBinding: Binding<PresentedAlert?> { $presentedAlert }
}

// MARK: Teams Logic
extension PlayersView: TeamsLogic {
    private func edit(team: Team) -> some View {
        EditTeamView(team: team, editTeam: editTeam)
    }
}

// MARK: PresentedAlert
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
        Group {
            PlayersView()
                .environmentObject(TeamsStore())
            PlayersView()
                .environmentObject(TeamsStore())
                .environment(\.colorScheme, .dark)
        }
    }
}
