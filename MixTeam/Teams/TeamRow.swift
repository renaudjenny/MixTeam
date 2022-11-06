import ComposableArchitecture
import SwiftUI

struct TeamRow: View {
    let store: StoreOf<Team>
    @State private var isRealRemoveButtonDisplayed = false

    var body: some View {
        Section {
            ForEachStore(store.scope(state: \.players, action: Team.Action.player), content: PlayerRow.init)
        } header: {
            header
        }
    }

    private var header: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Button { viewStore.send(.edit) } label: {
                    HStack {
                        viewStore.imageIdentifier.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                        Text(viewStore.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(DashedButtonStyle(color: viewStore.colorIdentifier.color))
                .padding(.trailing)

                Button { withAnimation { isRealRemoveButtonDisplayed = true } } label: {
                    Label("Remove Team", systemImage: "minus.circle")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.plain)
            }
            .blur(radius: isRealRemoveButtonDisplayed ? 2 : 0)
            .overlay {
                if isRealRemoveButtonDisplayed {
                    ZStack {
                        Button { withAnimation { isRealRemoveButtonDisplayed = false } } label: {
                            Color.clear
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        Button { viewStore.send(.delete, animation: .easeInOut) } label: {
                            VStack(spacing: 20) {
                                Text("Delete!")
                                Image(systemName: "minus.circle.fill")
                            }
                        }
                        .buttonStyle(DashedButtonStyle(color: .red))
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .background(viewStore.colorIdentifier.color)
            .listRowInsets(EdgeInsets())
        }
    }
}

#if DEBUG
struct TeamRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TeamRow(store: .preview)
        }
        .listStyle(.grouped)
        .previewDisplayName("Team Row Without Players")

        List {
            TeamRow(store: .previewWithPlayers)
        }
        .listStyle(.grouped)
        .previewDisplayName("Team Row With Players")
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
                List {
                    ForEachStore(store.scope(state: \.teams, action: App.Action.team), content: TeamRow.init)
                    Button { viewStore.send(.addTeam, animation: .easeInOut) } label: {
                        Text("Add Team")
                    }
                }
                .listStyle(.grouped)
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
