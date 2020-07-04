import SwiftUI

struct PlayersView: View, PlayersLogic {
    static let playersColorResetDelay: DispatchTimeInterval = .milliseconds(400)
    private static let shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.25)
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
        }
        .alert(item: $presentedAlert, content: alert(for:))
        .sheet(item: $editedPlayer, content: edit(player:))
        .navigationBarTitle("Players")
        .navigationBarItems(trailing: addPlayerButton)
    }

    private func teamRow(_ team: Team) -> some View {
        VStack {
            sectionHeader(team: team)
                .font(.callout)
                .foregroundColor(Color.white)
                .padding(.top)
            ForEach(team.players, content: playerRow)
                .onDelete(perform: { self.deletePlayer(in: team, at: $0) })
        }
        .background(team.colorIdentifier.color)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: .init(lineWidth: 2, dash: [5, 5], dashPhase: 3))
                .foregroundColor(Color.white)
                .padding(5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(
            color: Self.shadowColor,
            radius: 3, x: -2, y: 2
        )
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

    private func playerRow(_ player: Player) -> some View {
        Button(action: { self.editedPlayer = player }, label: {
            HStack {
                player.imageIdentifier.image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.leading, 40)
                    .padding(.trailing)
                Text(player.name)
                Spacer()
            }
            .foregroundColor(Color.white)
        })
        .buttonStyle(DefaultButtonStyle())
        .padding([.bottom], 20)
    }

    private func edit(player: Player) -> some View {
        EditPlayerView(player: player, editPlayer: editPlayer)
    }

    private var addPlayerButton: some View {
        NavigationLink(destination: AddPlayerView(createPlayer: createPlayer), label: {
            Image(systemName: "plus").accessibility(label: Text("Add"))
        })
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
        Group {
            PlayersView()
                .environmentObject(TeamsStore())
            PlayersView()
                .environmentObject(TeamsStore())
                .environment(\.colorScheme, .dark)
        }
    }
}
