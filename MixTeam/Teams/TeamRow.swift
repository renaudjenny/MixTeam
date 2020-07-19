import SwiftUI

struct TeamRow: View {
    let team: Team
    let isFirst: Bool
    let callbacks: Callbacks

    var body: some View {
        VStack {
            sectionHeader
                .font(.callout)
                .foregroundColor(Color.white)
                .padding(.top)
            ForEach(team.players) { player in
                PlayerRow(
                    player: player,
                    isInFirstTeam: self.isFirst,
                    callbacks: self.playerRowCallbacks
                )
            }
            if isFirst {
                addPlayerButton
            }
        }
        .frame(maxWidth: .infinity)
        .background(team.colorIdentifier.color)
        .modifier(AddDashedCardStyle())
        .modifier(AddSoftRemoveButton(remove: delete, isFirstTeam: isFirst))
        .frame(maxWidth: .infinity)
        .padding()
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
        .disabled(isFirst)
        .accessibility(label: Text("Edit Team \(team.name)"))
    }

    private var addPlayerButton: some View {
        Button(action: callbacks.createPlayer) {
            Image(systemName: "plus")
                .frame(width: 50, height: 50)
                .background(Color.white.clipShape(Circle()))
                .foregroundColor(.gray)
                .accessibility(label: Text("Add Player"))
        }.padding()
    }
}

extension TeamRow {
    struct Callbacks {
        let editTeam: (Team) -> Void
        let deleteTeam: (Team) -> Void
        let createPlayer: () -> Void
        let editPlayer: (Player) -> Void
        let moveBackPlayer: (Player) -> Void
        let deletePlayer: (Player) -> Void
    }

    private var playerRowCallbacks: PlayerRow.Callbacks {
        .init(
            edit: callbacks.editPlayer,
            delete: callbacks.deletePlayer,
            moveBack: callbacks.moveBackPlayer
        )
    }

    private func edit() { callbacks.editTeam(team) }
    private func delete() { callbacks.deleteTeam(team) }
}

//
//struct TeamRow_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            TeamRow(
//                team: Team(
//                    id: UUID(),
//                    name: "Team Test",
//                    colorIdentifier: .red,
//                    imageIdentifier: .koala,
//                    players: []
//                )
//            )
//            TeamRow(
//                team: Team(
//                    id: UUID(),
//                    name: "Team Test with Players",
//                    colorIdentifier: .blue,
//                    imageIdentifier: .octopus,
//                    players: [
//                        Player(name: "Player 1", imageIdentifier: .harryPottar),
//                        Player(name: "Player 2", imageIdentifier: .theBotman)
//                    ]
//                )
//            )
//            TeamRow(
//                team: Team(
//                    id: UUID(),
//                    name: "Players standing for a Team",
//                    colorIdentifier: .gray,
//                    imageIdentifier: .unknown,
//                    players: [
//                        Player(name: "Player 1", imageIdentifier: .harryPottar)
//                    ]
//                )
//            )
//        }
//    }
//}
//
//struct TeamRowUX_Previews: PreviewProvider {
//    static var previews: some View {
//        Preview()
//    }
//
//    private struct Preview: View {
//        @State private var teams: [Team] = [Team(
//            id: UUID(),
//            name: "Team Test",
//            colorIdentifier: .red,
//            imageIdentifier: .koala,
//            players: []
//        )]
//
//        var body: some View {
//            ScrollView {
//                ForEach(teams, content: teamRow)
//                Button(action: addTeam) {
//                    Text("Add Team")
//                }
//            }.animation(.default)
//        }
//
//        private func teamRow(_ team: Team) -> some View {
//            TeamRow(team: team).transition(.move(edge: .leading))
//        }
//
//        private func addTeam() {
//            teams.append(
//                Team(
//                    id: UUID(),
//                    name: "Team Test",
//                    colorIdentifier: ColorIdentifier.allCases.randomElement() ?? .red,
//                    imageIdentifier: ImageIdentifier.teams.randomElement() ?? .koala,
//                    players: []
//                )
//            )
//        }
//
//        private func deleteTeam(_ team: Team) {
//            guard let index = teams.firstIndex(of: team) else { return }
//            teams.remove(at: index)
//        }
//    }
//}
