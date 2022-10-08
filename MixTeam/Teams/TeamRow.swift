import ComposableArchitecture
import SwiftUI

struct TeamRow: View {
    let team: Team
    let store: StoreOf<App>

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            VStack {
                sectionHeader
                    .font(.callout)
                    .foregroundColor(Color.white)
                    .padding(.top)
                VStack {
                    ForEach(team.players) { player in
                        PlayerRow(
                            player: player,
                            isInFirstTeam: false,
                            store: store
                        )
                    }
                }.padding(.bottom)
            }
            .frame(maxWidth: .infinity)
            .background(team.colorIdentifier.color)
            .modifier(AddDashedCardStyle())
            .modifier(AddSoftRemoveButton(remove: { viewStore.send(.deleteTeam(team)) }))
            .padding()
        }
    }

    private var sectionHeader: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.editTeam(team)) } label: {
                VStack {
                    Text(team.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding([.leading, .trailing])
                    team.imageIdentifier.image
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(team.colorIdentifier.color)
                        .frame(width: 80, height: 80)
                        .padding()
                        .background(Color.white.clipShape(Splash2()))
                        .padding(.bottom)
                }
            }
            .accessibility(label: Text("Edit Team \(team.name)"))
        }
    }
}

#if DEBUG
struct TeamRow_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        var body: some View {
            Group {
                TeamRow(
                    team: Team(
                        id: UUID(),
                        name: "Team Test",
                        colorIdentifier: .red,
                        imageIdentifier: .koala,
                        players: []
                    ),
                    store: .preview
                )
                TeamRow(
                    team: Team(
                        id: UUID(),
                        name: "Team Test with Players",
                        colorIdentifier: .blue,
                        imageIdentifier: .octopus,
                        players: [
                            Player(name: "Player 1", imageIdentifier: .girl),
                            Player(name: "Player 2", imageIdentifier: .santa),
                        ]
                    ),
                    store: .preview
                )
                FirstTeamRow(
                    team: Team(
                        id: UUID(),
                        name: "Players standing for a Team",
                        colorIdentifier: .gray,
                        imageIdentifier: .unknown,
                        players: [
                            Player(name: "Player 1", imageIdentifier: .girl),
                        ]
                    ),
                    store: .preview
                )
            }
        }
    }
}

struct TeamRowUX_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        @State private var teams: [Team] = [.test]

        var body: some View {
            ScrollView {
                ForEach(teams, content: teamRow)
                Button(action: addTeam) {
                    Text("Add Team")
                }
            }
        }

        private func teamRow(_ team: Team) -> some View {
            TeamRow(team: team, store: .preview)
                .transition(.move(edge: .leading))
        }

        private func addTeam() {
            withAnimation {
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
        }
    }
}
#endif
