import SwiftUI

struct PlayerRow: View {
    let player: Player
    let isInFirstTeam: Bool
    let callbacks: Callbacks

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
                    isInFirstTeam: isInFirstTeam,
                    callbacks: playerRowButtonsCallbacks
                )
            }
            .foregroundColor(Color.white)
        }
        .padding(10)
    }
}

extension PlayerRow {
    struct Callbacks {
        let edit: (Player) -> Void
        let delete: (Player) -> Void
        let moveBack: (Player) -> Void
    }

    private var playerRowButtonsCallbacks: PlayerRowButtons.Callbacks {
        .init(delete: callbacks.delete, moveBack: callbacks.moveBack)
    }

    private func edit() { callbacks.edit(player) }
}

private struct PlayerRowButtons: View {
    let player: Player
    let isInFirstTeam: Bool
    let callbacks: Callbacks

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

extension PlayerRowButtons {
    struct Callbacks {
        let delete: (Player) -> Void
        let moveBack: (Player) -> Void
    }

    private func delete() { callbacks.delete(player) }
    private func moveBack() { callbacks.moveBack(player) }
}

struct PlayerRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack() {
            PlayerRow(
                player: Player(
                    id: UUID(),
                    name: "Test",
                    imageIdentifier: .harryPottar
                ),
                isInFirstTeam: true,
                callbacks: callbacks
            )
            Color.white.frame(height: 20)
            PlayerRow(
                player: Player(
                    id: UUID(),
                    name: "Test",
                    imageIdentifier: .harryPottar
                ),
                isInFirstTeam: false,
                callbacks: callbacks
            )
        }.background(Color.red)
    }

    private static let callbacks: PlayerRow.Callbacks = .init(
        edit: { _ in },
        delete: { _ in },
        moveBack: { _ in }
    )
}
