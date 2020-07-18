import SwiftUI

struct TeamRow: View {
    @EnvironmentObject var teamsStore: TeamsStore
    let team: Team
    @State private var isEdited = false
    // TODO: find why we can't edit player directly in the PlayerRow View...
    @State private var editedPlayer: Player?
    // TODO: add a dummyCallback otherwise ScrollView won't update the Players
    // check if this bug is still present in Xcode 12 and iOS 14
    let dummyCallback: () -> Void

    var body: some View {
        VStack {
            sectionHeader
                .font(.callout)
                .foregroundColor(Color.white)
                .padding(.top)
            ForEach(team.players) { player in
                PlayerRow(player: player, edit: {
                    self.editedPlayer = player
                })
            }
            if isFirstTeam {
                addPlayerButton
            }
        }
        .frame(maxWidth: .infinity)
        .background(team.colorIdentifier.color)
        .modifier(AddDashedCardStyle())
        .modifier(AddSoftRemoveButton(remove: delete, isFirstTeam: isFirstTeam))
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.clear.sheet(item: $editedPlayer) {
            EditPlayerView(
                player: self.bind(player: $0),
                team: self.team
            )
        })
        .background(Color.clear.sheet(isPresented: $isEdited) {
            EditTeamView(team: self.bind(team: self.team))
        })
    }

    private var sectionHeader: some View {
        Button(action: edit) {
            VStack {
                Text(team.name).padding([.leading, .trailing])
                team.imageIdentifier.image
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(team.colorIdentifier.color)
                    .frame(width: 50, height: 50)
                    .padding()
                    .background(Color.white.clipShape(Circle()))
                    .padding(.bottom)
            }
        }
        .disabled(isFirstTeam)
        .accessibility(label: Text("Edit Team \(team.name)"))
    }

    private var addPlayerButton: some View {
        Button(action: createPlayer, label: {
            Image(systemName: "plus")
                .frame(width: 50, height: 50)
                .background(Color.white.clipShape(Circle()))
                .foregroundColor(.gray)
                .accessibility(label: Text("Add Player"))
        }).padding()
    }
}

extension TeamRow: TeamsLogic {
    var isFirstTeam: Bool { isFirstTeam(team) }
    private func delete() { delete(team: team) }
    private func edit() { isEdited = true }
}

extension TeamRow: PlayersLogic {
    private func createPlayer() { createRandomPlayer() }
}

struct TeamRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TeamRow(
                team: Team(
                    id: UUID(),
                    name: "Team Test",
                    colorIdentifier: .red,
                    imageIdentifier: .koala,
                    players: []
                ),
                dummyCallback: { }
            )
            TeamRow(
                team: Team(
                    id: UUID(),
                    name: "Team Test with Players",
                    colorIdentifier: .blue,
                    imageIdentifier: .octopus,
                    players: [
                        Player(name: "Player 1", imageIdentifier: .harryPottar),
                        Player(name: "Player 2", imageIdentifier: .theBotman)
                    ]
                ),
                dummyCallback: { }
            )
            TeamRow(
                team: Team(
                    id: UUID(),
                    name: "Players standing for a Team",
                    colorIdentifier: .gray,
                    imageIdentifier: .unknown,
                    players: [
                        Player(name: "Player 1", imageIdentifier: .harryPottar)
                    ]
                ),
                dummyCallback: { }
            )
        }
    }
}

struct TeamRowUX_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        @State private var teams: [Team] = [Team(
            id: UUID(),
            name: "Team Test",
            colorIdentifier: .red,
            imageIdentifier: .koala,
            players: []
        )]

        var body: some View {
            ScrollView {
                ForEach(teams, content: teamRow)
                Button(action: addTeam) {
                    Text("Add Team")
                }
            }.animation(.default)
        }

        private func teamRow(_ team: Team) -> some View {
            TeamRow(team: team, dummyCallback: { }).transition(.move(edge: .leading))
        }

        private func addTeam() {
            teams.append(
                Team(
                    id: UUID(),
                    name: "Team Test",
                    colorIdentifier: ColorIdentifier.allCases.randomElement() ?? .red,
                    imageIdentifier: ImageIdentifier.teams.randomElement() ?? .koala,
                    players: []
                )
            )
        }

        private func deleteTeam(_ team: Team) {
            guard let index = teams.firstIndex(of: team) else { return }
            teams.remove(at: index)
        }
    }
}
