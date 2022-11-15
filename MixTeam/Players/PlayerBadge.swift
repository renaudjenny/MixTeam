import SwiftUI
import Dependencies

struct PlayerBadge: View {
    let player: Player.State

    var body: some View {
        player.image.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(8)
            .opacity(70/100)
            .background(color: player.color)
            .modifier(AddDashedCardStyle())
    }
}

#if DEBUG
struct PlayerBadge_Previews: PreviewProvider {
    static var previews: some View {
        PlayerBadge(player: .preview)
            .padding()
    }
}

extension Player.State {
    static func preview(isStanding: Bool = false) -> Self {
        guard let image = ImageIdentifier.players.randomElement(),
              let color = ColorIdentifier.allCases.randomElement()
        else { fatalError("Cannot generate image & color as expected") }

        return Player.State(
            id: UUIDGenerator.incrementing(),
            name: "Test Player",
            image: image,
            isStanding: isStanding,
            color: isStanding ? .gray : color
        )
    }
    static var preview: Self {
        .preview()
    }
}
#endif
