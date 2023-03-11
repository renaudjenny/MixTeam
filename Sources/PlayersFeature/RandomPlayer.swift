import Assets
import Dependencies
import Foundation
import XCTestDynamicOverlay

struct RandomPlayerDepedencyKey: DependencyKey {
    static let liveValue: RandomPlayer = .live
    static let testValue: RandomPlayer = .test
    static let previewValue: RandomPlayer = .amelie
}
public extension DependencyValues {
    var randomPlayer: RandomPlayer {
        get { self[RandomPlayerDepedencyKey.self] }
        set { self[RandomPlayerDepedencyKey.self] = newValue }
    }
}

public struct RandomPlayer {
    let random: () -> Player.State

    public init(random: @escaping () -> Player.State) {
        self.random = random
    }

    static let live = Self {
        @Dependency(\.uuid) var uuid

        let name = ["Mathilde", "Renaud", "John", "Alice", "Bob", "CJ"].randomElement() ?? ""
        let image = MTImage.players.randomElement() ?? .unknown
        return Player.State(id: uuid(), name: name, image: image, color: .aluminium)
    }
    static let test = Self {
        XCTFail(#"Unimplemented: @Dependency(\.shufflePlayers)"#)
        return live.random()
    }
    static let amelie = Self {
        @Dependency(\.uuid) var uuid

        let image: MTImage = .amelie
        let name = "Amelie"
        return Player.State(id: uuid(), name: name, image: image, color: .aluminium)
    }

    public func callAsFunction() -> Player.State {
        random()
    }
}
