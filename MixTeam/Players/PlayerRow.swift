import SwiftUI

struct PlayerRow: View {
    let player: Player
    let isInFirstTeam: Bool
    let edit: () -> Void
    let delete: () -> Void
    let moveBack: () -> Void

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
                    isInFirstTeam: isInFirstTeam,
                    delete: delete,
                    moveBack: moveBack
                )
            }
            .foregroundColor(Color.white)
        }
        .padding(10)
    }
}

private struct PlayerRowButtons: View {
    let isInFirstTeam: Bool
    let delete: () -> Void
    let moveBack: () -> Void

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

struct PlayerRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayerRow(
                player: Player(
                    id: UUID(),
                    name: "Test",
                    imageIdentifier: .harryPottar
                ),
                isInFirstTeam: false,
                edit: { },
                delete: { },
                moveBack: { }
            )
            PlayerRow(
                player: Player(
                    id: UUID(),
                    name: "Test",
                    imageIdentifier: .harryPottar
                ),
                isInFirstTeam: true,
                edit: { },
                delete: { },
                moveBack: { }
            )
        }.background(Color.red)
    }
}
