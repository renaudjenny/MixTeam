import SwiftUI

struct PlayersView: View, PlayersLogic {
    static let playersColorResetDelay: DispatchTimeInterval = .milliseconds(400)
    static let shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.25)
    @EnvironmentObject var teamsStore: TeamsStore
    @State private var editedPlayer: Player?
    @State private var presentedAlert: PresentedAlert?
    var presentedAlertBinding: Binding<PresentedAlert?> { $presentedAlert }

    var body: some View {
        NavigationView {
            playersView
        }
    }

    private var playersView: some View {
        ScrollView {
            teamRow(teams.first ?? Team())
            mixTeamButton
            ForEach(teams.dropFirst(), content: teamRow)
            addTeamButton
        }
        .animation(.default)
        .alert(item: $presentedAlert, content: alert(for:))
        .sheet(item: $editedPlayer, content: edit(player:))
        .navigationBarTitle("Players")
    }

    private func teamRow(_ team: Team) -> some View {
        VStack {
            sectionHeader(team: team)
                .font(.callout)
                .foregroundColor(Color.white)
                .padding(.top)
            ForEach(team.players) { player in
                PlayerRow(
                    player: player,
                    isInFirstTeam: self.teams.first == team,
                    edit: { self.editedPlayer = player },
                    delete: { self.deletePlayer(player) },
                    moveBack: { self.moveBack(player: player) }
                )
            }
            if isFirstTeam(team) {
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

    private func edit(player: Player) -> some View {
        EditPlayerView(player: player, editPlayer: editPlayer)
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
        NavigationLink(destination: AddTeamView(createTeam: { _ in }), label: {
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

    private func isFirstTeam(_ team: Team) -> Bool { teams.first == team }
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

private struct PlayerRow: View {
    let player: Player
    let isInFirstTeam: Bool
    let edit: () -> Void
    let delete: () -> Void
    let moveBack: () -> Void

    var body: some View {
        Button(action: edit) {
            HStack {
                player.imageIdentifier.image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding([.leading, .trailing])
                Text(player.name)
                Spacer()
                PlayerRowButtons(
                    isInFirstTeam: isInFirstTeam,
                    delete: delete,
                    moveBack: moveBack
                )
            }
            .foregroundColor(Color.white)
        }
        .padding([.bottom], 20)
    }
}

private struct PlayerRowButtons: View {
    let isInFirstTeam: Bool
    let delete: () -> Void
    let moveBack: () -> Void

    @ViewBuilder var body: some View {
        if isInFirstTeam {
            Button(action: delete) {
                Image(systemName: "minus.circle.fill")
            }.padding(.trailing)
        } else {
            Button(action: moveBack) {
                Image(systemName: "gobackward")
            }.padding(.trailing)
        }
    }
}

struct AddDashedCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: .init(lineWidth: 2, dash: [5, 5], dashPhase: 3))
                    .foregroundColor(Color.white)
                    .padding(5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(
                color: PlayersView.shadowColor,
                radius: 3, x: -2, y: 2
            )
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
