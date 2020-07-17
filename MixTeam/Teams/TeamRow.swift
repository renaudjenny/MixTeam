import SwiftUI

struct TeamRow: View {
    @EnvironmentObject var teamsStore: TeamsStore
    @State private var isEdited = false
    let team: Team
    let isFirstTeam: Bool
    let editPlayer: (Player) -> Void
    let deletePlayer: (Player) -> Void
    let moveBackPlayer: (Player) -> Void

    var body: some View {
        VStack {
            sectionHeader
                .font(.callout)
                .foregroundColor(Color.white)
                .padding(.top)
            ForEach(team.players) { player in
                PlayerRow(
                    player: player,
                    isInFirstTeam: self.isFirstTeam,
                    edit: { self.editPlayer(player) },
                    delete: { self.deletePlayer(player) },
                    moveBack: { self.moveBackPlayer(player) }
                )
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
        .sheet(isPresented: $isEdited, content: {
            // TODO: modify EditTeamView to accepted just a Team binding
            EditTeamView(team: self.team, editTeam: self.edit(team:))
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
    private func delete() { delete(team: team) }
    private func edit() { isEdited = true }

    private func edit(team: Team) -> some View {
        EditTeamView(team: team, editTeam: edit(team:))
    }
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
                isFirstTeam: false,
                editPlayer: { _ in },
                deletePlayer: { _ in },
                moveBackPlayer: { _ in }
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
                isFirstTeam: false,
                editPlayer: { _ in },
                deletePlayer: { _ in },
                moveBackPlayer: { _ in }
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
                isFirstTeam: true,
                editPlayer: { _ in },
                deletePlayer: { _ in },
                moveBackPlayer: { _ in }
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
            TeamRow(
                team: team,
                isFirstTeam: false,
                editPlayer: { _ in },
                deletePlayer: { _ in },
                moveBackPlayer: { _ in }
            ).transition(.move(edge: .leading))
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
