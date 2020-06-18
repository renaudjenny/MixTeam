import SwiftUI

struct PlayersView: View, PlayersLogic {
    static let playersColorResetDelay: DispatchTimeInterval = .milliseconds(400)
    @EnvironmentObject var teamsStore: TeamsStore
    @State private var editedPlayer: Player? = nil
    @State private var presentedAlert: PresentedAlert?
    var presentedAlertBinding: Binding<PresentedAlert?> { $presentedAlert }

    var body: some View {
        NavigationView {
            playersView
        }
    }

    private var playersView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(teams, content: teamRow)
            }
            .listStyle(GroupedListStyle())
            Button(action: mixTeam) {
                HStack {
                    Image(systemName: "shuffle")
                    Text("Mix Team")
                }
            }
            .buttonStyle(MixTeamButtonStyle())
            .frame(height: 50)
            .shadow(radius: 10)
        }
        .alert(item: $presentedAlert, content: alert(for:))
        .sheet(item: $editedPlayer, content: edit(player:))
        .navigationBarTitle("Players")
        .navigationBarItems(trailing: addPlayerButton)
    }

    private func teamRow(_ team: Team) -> some View {
        Section(header: sectionHeader(team: team)) {
            ForEach(team.players, content: playerRow)
                .onDelete(perform: { self.deletePlayer(in: team, at: $0) })
                .background(team.colorIdentifier.color.opacity(0.10))
        }
    }

    private func sectionHeader(team: Team) -> some View {
        HStack {
            team.imageIdentifier.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding([.leading, .top, .bottom])
            Text(team.name)
                .font(.headline)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .listRowInsets(EdgeInsets())
        .background(team.colorIdentifier.color.opacity(0.20))
    }

    private func playerRow(_ player: Player) -> some View {
        Button(action: { self.editedPlayer = player }) {
            HStack {
                player.imageIdentifier.image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.leading, 40)
                    .padding(.trailing)
                Text(player.name)
                Spacer()
            }.foregroundColor(color(for: player))
        }
        .buttonStyle(DefaultButtonStyle())
        .padding([.top, .bottom], 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowInsets(EdgeInsets())
    }

    private func edit(player: Player) -> some View {
        guard let player = playerBinding(for: player) else {
            return EmptyView().eraseToAnyView()
        }
        return EditPlayerView(playerName: player.name, imageIdentifier: player.imageIdentifier)
            .eraseToAnyView()
    }

    private var addPlayerButton: some View {
        NavigationLink(destination: AddPlayerView(createPlayer: createPlayer), label: { Image(systemName: "plus") })
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
}

class PlayersHostingController: UIHostingController<PlayersView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: PlayersView())
    }
}
