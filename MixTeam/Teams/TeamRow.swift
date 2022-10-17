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
        TeamRow(store: .preview).previewDisplayName("Team Row Without Players")
        TeamRow(store: .previewWithPlayers).previewDisplayName("Team Row With Players")
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
                    ForEachStore(store.scope(state: \.teams, action: App.Action.team), content: TeamRow.init)
                    Button { viewStore.send(.addTeam) } label: {
                        Text("Add Team")
                    }
                }
            }
        }
    }
}

extension Store where State == Team.State, Action == Team.Action {
    static var preview: Self {
        Self(initialState: .preview, reducer: Team())
    }
    static var previewWithPlayers: Self {
        Self(
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
