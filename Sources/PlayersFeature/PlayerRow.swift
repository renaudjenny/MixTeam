import Assets
import ComposableArchitecture
import SwiftUI

public struct PlayerRow: View {
    let store: StoreOf<Player>

    public init(store: StoreOf<Player>) {
        self.store = store
    }

    public var body: some View {
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
        #if os(iOS)
        .listRowSeparator(.hidden)
        #endif
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
