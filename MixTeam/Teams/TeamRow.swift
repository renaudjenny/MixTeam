import ComposableArchitecture
import SwiftUI

struct TeamRow: View {
    let store: StoreOf<Team>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                sectionHeader
                    .font(.callout)
                    .foregroundColor(Color.white)
                    .padding(.top)
                VStack {
                    ForEachStore(store.scope(state: \.players, action: Team.Action.player), content: PlayerRow.init)
                }.padding(.bottom)
            }
            .frame(maxWidth: .infinity)
            .background(viewStore.colorIdentifier.color)
            .modifier(AddDashedCardStyle())
            .modifier(AddSoftRemoveButton(remove: { viewStore.send(.delete) }))
            .padding()
        }
    }

    private var sectionHeader: some View {
        WithViewStore(store) { viewStore in
            Button { viewStore.send(.edit) } label: {
                VStack {
                    Text(viewStore.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding([.leading, .trailing])
                    viewStore.imageIdentifier.image
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(viewStore.colorIdentifier.color)
                        .frame(width: 80, height: 80)
                        .padding()
                        .background(Color.white.clipShape(Splash2()))
                        .padding(.bottom)
                }
            }
            .accessibility(label: Text("Edit Team \(viewStore.name)"))
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
                TeamRow(store: .preview)
                TeamRow(store: .previewWithPlayers)
                StandingView(store: .preview)
            }
        }
    }
}

struct TeamRowUX_Previews: PreviewProvider {
    static var previews: some View {
        Preview(store: .preview)
    }

    private struct Preview: View {
        let store: StoreOf<App>

        var body: some View {
            WithViewStore(store) { viewStore in
                ScrollView {
                    ForEachStore(store.scope(state: \.teams, action: App.Action.team), content: teamRow)
                    Button { viewStore.send(.addTeam) } label: {
                        Text("Add Team")
                    }
                }
            }
        }

        private func teamRow(_ team: StoreOf<Team>) -> some View {
            TeamRow(store: team)
                .transition(.move(edge: .leading))
        }
    }
}

extension StoreOf<Team> {
    static var preview: StoreOf<Team> {
        Store(initialState: .preview, reducer: Team())
    }
    static var previewWithPlayers: StoreOf<Team> {
        Store(
            initialState: Team.State(
                id: UUID(),
                name: "Team test",
                colorIdentifier: .blue,
                imageIdentifier: .octopus,
                players: [
                    Player.State(id: UUID(), name: "Player 1", image: .girl, color: .blue),
                    Player.State(id: UUID(), name: "Player 2", image: .santa, color: .blue),
                ]
            ),
            reducer: Team()
        )
    }
}

extension Team.State {
    static var preview: Self {
        Team.State(
            id: UUID(),
            name: "Team test",
            colorIdentifier: ColorIdentifier.allCases.randomElement() ?? .red,
            imageIdentifier: ImageIdentifier.teams.randomElement() ?? .koala
        )
    }
}
#endif
