import SwiftUI

struct TeamRow: View {
    let team: Team
    let isFirstTeam: Bool
    let editPlayer: (Player) -> Void
    let deletePlayer: (Player) -> Void
    let moveBackPlayer: (Player) -> Void
    let createPlayer: (String, ImageIdentifier) -> Void
    let deleteTeam: (Team) -> Void

    var body: some View {
        VStack {
            sectionHeader(team: team)
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
        .background(team.colorIdentifier.color)
        .modifier(AddDashedCardStyle())
        .modifier(AddSoftRemoveButton(remove: removeTeam, isFirstTeam: isFirstTeam))
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

    private var addPlayerButton: some View {
        NavigationLink(destination: AddPlayerView(createPlayer: createPlayer), label: {
            Image(systemName: "plus")
                .frame(width: 50, height: 50)
                .background(Color.white.clipShape(Circle()))
                .foregroundColor(.gray)
                .accessibility(label: Text("Add Player"))
        }).padding()
    }

    private func removeTeam() {
        deleteTeam(team)
    }
}

// TODO: move this to its own file
struct AddSoftRemoveButton: ViewModifier {
    let remove: () -> Void
    let isFirstTeam: Bool
    @State private var isRealRemoveButtonDisplayed = false

    func body(content: Content) -> some View {
        HStack {
            contentAndMinusButton(content).overlay(filterIfNeeded)
            if isRealRemoveButtonDisplayed {
                deleteButton.transition(.move(edge: .trailing))
            }
        }.animation(.default)
    }

    private func contentAndMinusButton(_ content: Content) -> some View {
        content.overlay(minusButton, alignment: .topTrailing)
    }

    private var minusButton: some View {
        VStack {
            if !isRealRemoveButtonDisplayed && !isFirstTeam {
                Button(action: displayRealRemoveButton) {
                    Image(systemName: "minus.circle")
                }
            }
        }
        .foregroundColor(.white)
        .padding()
    }

    private var deleteButton: some View {
        VStack(spacing: 20) {
            Button(action: remove) {
                VStack {
                    Text("Delete!")
                    Image(systemName: "minus.circle.fill")
                }
            }
            .foregroundColor(.white)
            .padding()
        }
        .background(Color.red)
        .modifier(AddDashedCardStyle())
    }

    @ViewBuilder private var filterIfNeeded: some View {
        Button(action: hideRealRemoveButton) {
            Color.black
                .opacity(isRealRemoveButtonDisplayed ? 2/10 : 0)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }.allowsHitTesting(isRealRemoveButtonDisplayed)
    }

    private func displayRealRemoveButton() {
        isRealRemoveButtonDisplayed = true
    }

    private func hideRealRemoveButton() {
        isRealRemoveButtonDisplayed = false
    }
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
                moveBackPlayer: { _ in },
                createPlayer: { _, _ in },
                deleteTeam: { _ in }
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
                moveBackPlayer: { _ in },
                createPlayer: { _, _ in },
                deleteTeam: { _ in }
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
                moveBackPlayer: { _ in },
                createPlayer: { _, _ in },
                deleteTeam: { _ in }
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
                moveBackPlayer: { _ in },
                createPlayer: { _, _ in },
                deleteTeam: deleteTeam
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
