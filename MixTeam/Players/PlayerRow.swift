import ComposableArchitecture
import SwiftUI

struct PlayerRow: View {
    let store: StoreOf<Player>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationLink(destination: EditPlayerView(store: store)) {
                HStack {
                    Image(mtImage: viewStore.image)
                        .resizable()
                        .frame(width: 48, height: 48)
                    Text(viewStore.name)
                        .fontWeight(.medium)
                }
            }
            .backgroundAndForeground(color: viewStore.color)
            .padding(.leading, 24)
            .swipeActions(allowsFullSwipe: true) {
                if viewStore.isStanding {
                    Button(role: .destructive) { viewStore.send(.delete, animation: .easeInOut) } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                } else {
                    Button { viewStore.send(.moveBack, animation: .easeInOut) } label: {
                        Image(systemName: "gobackward")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#if DEBUG
struct PlayerRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(0..<2) {
                PlayerRow(store: .preview(isStanding: $0 != 1))
            }
        }
        .listStyle(.plain)
        .listRowSeparator(.hidden)
    }
}

extension Store where State == Player.State, Action == Player.Action {
    static func preview(isStanding: Bool = false) -> Self {
        Self(initialState: .preview(isStanding: isStanding), reducer: Player())
    }
    static var preview: Self {
        .preview()
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
