import SwiftUI

// TODO: rename this, as it's more generic now
struct PlayerImagePicker: View {
    let team: Team
    @Binding var selection: ImageIdentifier
    let type: ImagePickerType

    let columns = 2
    let rows = 3

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                grid.animation(.default)
            }
        }
        .frame(maxWidth: .infinity)
        .background(team.colorIdentifier.color)
        .modifier(AddDashedCardStyle())
        .padding()
    }

    var grid: some View {
        HStack {
            ForEach(0..<columns) { column in
                VStack {
                    ForEach(0..<self.rows) { row in
                        VStack {
                            self.content(row: row, column: column)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder private func content(row: Int, column: Int) -> some View {
        if type == .player && row * columns + column < ImageIdentifier.players.count {
            Cell(imageIdentifier: ImageIdentifier.players[row * columns + column], team: team, selection: $selection)
        } else if type == .team && row * columns + column < ImageIdentifier.teams.count {
            Cell(imageIdentifier: ImageIdentifier.teams[row * columns + column], team: team, selection: $selection)
        } else {
            EmptyView()
        }
    }
}

private struct Cell: View {
    let imageIdentifier: ImageIdentifier
    let team: Team
    @Binding var selection: ImageIdentifier

    var body: some View {
        Button(action: select) {
            imageIdentifier.image
                .resizable()
                .frame(width: 80, height: 80)
                .padding()
                .foregroundColor(imageForegroundColor)
        }
        .background(
            Group {
                if selection.rawValue == imageIdentifier.rawValue {
                    Circle()
                }
            }
        )
            .foregroundColor(Color.white)
            .padding()
    }

    private func select() {
        selection = imageIdentifier
    }

    private var imageForegroundColor: Color {
        if selection == imageIdentifier {
            return team.colorIdentifier.color
        } else {
            return .white
        }

    }
}

extension PlayerImagePicker {
    enum ImagePickerType {
        case team, player
    }
}

struct PlayerImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .environmentObject(TeamsStore())
    }

    struct Preview: View {
        @EnvironmentObject var teamsStore: TeamsStore
        var selection: Binding<ImageIdentifier> {
            $teamsStore.teams[1].players[0].imageIdentifier
        }

        var body: some View {
            VStack {
                PlayerImagePicker(
                    team: teamsStore.teams[1],
                    selection: selection,
                    type: .player
                )
                Spacer()
                TeamRow(
                    team: teamsStore.teams[1],
                    isFirstTeam: false,
                    editPlayer: { _ in },
                    deletePlayer: { _ in },
                    moveBackPlayer: { _ in },
                    createPlayer: { },
                    editTeam: { _ in },
                    deleteTeam: { _ in }
                )
                Text("Selection: \(selection.wrappedValue.rawValue)")
            }
        }
    }
}
