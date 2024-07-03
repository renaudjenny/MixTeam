import ComposableArchitecture
import Foundation
import Models

public extension Player.State {
    var persisted: PersistedPlayer {
        PersistedPlayer(id: id, name: name, image: image)
    }
}

public extension PersistedPlayer {
    var state: Player.State {
        Player.State(id: id, name: name, image: image)
    }
}

public extension IdentifiedArrayOf<Player.State> {
    static var example: Self {
        return Self(uniqueElements: IdentifiedArrayOf<PersistedPlayer>.example.map {
            Player.State(id: $0.id, name: $0.name, image: $0.image)
        })
    }
}
