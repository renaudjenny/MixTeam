import Assets
import ComposableArchitecture
import SwiftUI

public struct PlayerRow: View {
    let store: StoreOf<Player>

    public init(store: StoreOf<Player>) {
        self.store = store
    }

    public var body: some View {
        NavigationLink(destination: EditPlayerView(store: store)) {
            HStack {
                Image(mtImage: store.image)
                    .resizable()
                    .frame(width: 48, height: 48)
                Text(store.name)
                    .fontWeight(.medium)
            }
        }
        .backgroundAndForeground(color: store.color)
        .padding(.leading, 24)
    }
}

#Preview {
    List {
        ForEach(0..<2) {
            PlayerRow(store: Store(initialState: .preview(isStanding: $0 != 1)) { Player() })
        }
    }
    .listStyle(.plain)
    #if os(iOS)
    .listRowSeparator(.hidden)
    #endif
}

#if DEBUG
public extension Player.State {
    static func preview(isStanding: Bool = false) -> Self {
        Player.State(
            id: UUIDGenerator.incrementing(),
            name: "Test Player",
            image: MTImage.amelie,
            color: isStanding ? .aluminium : .strawberry
        )
    }
    static var preview: Self {
        .preview()
    }
}
#endif
