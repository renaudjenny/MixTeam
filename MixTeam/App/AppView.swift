import SwiftUI
import RenaudJennyAboutView

struct AppView: View {
    @EnvironmentObject var teamsStore: TeamsStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var presentedAlert: PresentedAlert?
    @State private var editedTeam: Team?
    @State private var editedPlayer: Player?
    @State private var isAboutPresented = false
    @State private var isScoreboardPresented = false
    private let buttonSize = CGSize(width: 60, height: 60)

    var body: some View {
        ScrollView {
            LazyVStack {
                header
                teamsStore.teams.first.map { FirstTeamRow(team: $0, callbacks: firstTeamCallbacks) }
                mixTeamButton
                ForEach(teamsStore.teams.dropFirst(), content: teamRow)
                addTeamButton
            }
        }
        .frame(maxWidth: 800)
        .alert(item: $presentedAlert, content: alert(for:))
        .background(Color.clear.sheet(item: $editedTeam) {
            teamsStore.teams.firstIndex(of: $0).map {
                EditTeamView(team: $teamsStore.teams[$0])
            }
        })
        .background(Color.clear.sheet(item: $editedPlayer) { player in
            teamsStore.teams.firstIndex(where: { team in team.players.contains(player) }).map { teamIndex in
                teamsStore.teams[teamIndex].players.firstIndex(of: player).map { playerIndex in
                    EditPlayerView(
                        player: .init(
                            get: { teamsStore.teams[teamIndex].players[playerIndex] },
                            set: { teamsStore.teams[teamIndex].players.updateOrAppend($0) }
                        ),
                        team: teamsStore.teams[teamIndex]
                    )
                }
            }
        })
        .background(Color.clear.sheet(isPresented: $isScoreboardPresented) {
            ScoreboardView()
                .environmentObject(teamsStore)
        })
        .background(Color.clear.sheet(isPresented: $isAboutPresented) {
            RenaudJennyAboutView.AboutView(appId: "id1526493495", isInModal: true) {
                Image(uiImage: #imageLiteral(resourceName: "Logo"))
                    .cornerRadius(16)
                    .padding()
                    .padding(.top)
                    .shadow(radius: 5)
            } background: {
                Group {
                    colorScheme == .light
                        ? Color.gray.opacity(1/2)
                        : Color.black.opacity(3/4)
                }
                .modifier(AddDashedCardStyle())
                .shadow(radius: 6)
            }
        })
    }

    private var header: some View {
        HStack {
            scoreboardButton
            Spacer()
            Text("Mix Team")
                .font(.largeTitle)
                .fontWeight(.black)
            Spacer()
            aboutButton
        }
        .padding(.vertical)
    }

    private var scoreboardButton: some View {
        Button { isScoreboardPresented = true } label: {
            Image(systemName: "list.bullet.rectangle")
                .resizable()
                .padding(14)
        }
        .frame(width: buttonSize.width, height: buttonSize.height)
        .modifier(Shadow())
        .buttonStyle(MixTeamButtonStyle(color: .purple))
        .padding(.horizontal)
        .accessibility(label: Text("Display scoreboard"))
    }

    private var aboutButton: some View {
        Button { isAboutPresented = true } label: {
            Image(systemName: "cube.box")
                .resizable()
                .padding(12)
        }
        .frame(width: buttonSize.width, height: buttonSize.height)
        .modifier(Shadow())
        .buttonStyle(MixTeamButtonStyle(color: .gray))
        .padding(.horizontal)
        .accessibility(label: Text("About"))
    }

    private func teamRow(team: Team) -> some View {
        TeamRow(team: team, callbacks: teamCallbacks)
            .transition(.move(edge: .leading))
    }

    private var mixTeamButton: some View {
        Button(action: mixTeam) {
            HStack {
                Image(systemName: "shuffle")
                Text("Mix Team")
            }
        }
        .modifier(Shadow())
        .buttonStyle(MixTeamButtonStyle())
        .frame(height: 50)
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
extension AppView: MixTeamLogic {
    var presentedAlertBinding: Binding<PresentedAlert?> { $presentedAlert }
}

// MARK: Teams Logic
extension AppView: TeamsLogic {
    var firstTeamCallbacks: FirstTeamRow.Callbacks {
        .init(
            createPlayer: createRandomPlayer,
            editPlayer: { editedPlayer = $0 },
            deletePlayer: delete(player:)
        )
    }

    var teamCallbacks: TeamRow.Callbacks {
        .init(
            editTeam: { editedTeam = $0 },
            deleteTeam: delete(team:),
            editPlayer: { editedPlayer = $0 },
            moveBackPlayer: moveBack(player:)
        )
    }
}

// MARK: PresentedAlert
extension AppView {
    enum PresentedAlert: Identifiable {
        case notEnoughTeams

        var id: Int { hashValue }
    }

    private func alert(for identifier: PresentedAlert) -> Alert {
        Alert(title: Text("Couldn't Mix Team with less than 2 teams. Go create some teams :)"))
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppView()
                .environmentObject(TeamsStore())
            AppView()
                .environmentObject(TeamsStore())
                .environment(\.colorScheme, .dark)
        }
    }
}
