import SwiftUI

struct PlayerRow: View {
    @EnvironmentObject var teamsStore: TeamsStore
    let player: Player
    let edit: () -> Void

    var body: some View {
        Button(action: edit) {
            HStack {
                player.imageIdentifier.image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding([.leading, .trailing])
                Text(player.name)
                Spacer()
                PlayerRowButtons(
                    player: player,
                    isInFirstTeam: isInFirstTeam
                )
            }
            .foregroundColor(Color.white)
        }
        .padding(10)
    }
}

extension PlayerRow: PlayersLogic, TeamsLogic {
    private var isInFirstTeam: Bool { isFirstTeam(team(of: player)) }
}

private struct PlayerRowButtons: View {
    @EnvironmentObject var teamsStore: TeamsStore
    let player: Player
    let isInFirstTeam: Bool

    @ViewBuilder var body: some View {
        if isInFirstTeam {
            Button(action: delete) {
                Image(systemName: "minus.circle.fill")
            }.padding(.trailing)
        } else {
            Button(action: moveBack) {
                Image(systemName: "gobackward")
            }.padding(.trailing)
        }
    }
}

extension PlayerRowButtons: PlayersLogic {
    private func delete() { delete(player: player) }
    private func moveBack() { moveBack(player: player) }
}

struct PlayerRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayerRow(
                player: Player(
                    id: UUID(),
                    name: "Test",
                    imageIdentifier: .harryPottar
                ),
                edit: { }
            )
            PlayerRow(
                player: Player(
                    id: UUID(),
                    name: "Test",
                    imageIdentifier: .harryPottar
                ),
                edit: { }
            )
        }.background(Color.red)
    }
}
