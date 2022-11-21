import SwiftUI
import Dependencies

struct PlayerBadge: View {
    let player: Player.State

    var body: some View {
        Image(mtImage: player.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(8)
            .opacity(70/100)
            .backgroundAndForeground(color: player.color)
            .dashedCardStyle()
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
        guard let image = MTImage.players.randomElement(),
              let color = MTColor.allCases.filter({ $0 != .aluminium }).randomElement()
        else { fatalError("Cannot generate image & color as expected") }

        return Player.State(
            id: UUIDGenerator.incrementing(),
            name: "Test Player",
            image: image,
            color: isStanding ? .aluminium : color,
            isStanding: isStanding
        )
    }
    static var preview: Self {
        .preview()
    }
}
#endif
