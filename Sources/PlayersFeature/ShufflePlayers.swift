import Dependencies
import XCTestDynamicOverlay

struct ShufflePlayersDepedencyKey: DependencyKey {
    static let liveValue: ShufflePlayers = .live
    static let testValue: ShufflePlayers = .test
    static let previewValue: ShufflePlayers = .alphabeticallySorted
}

public extension DependencyValues {
    var shufflePlayers: ShufflePlayers {
        get { self[ShufflePlayersDepedencyKey.self] }
        set { self[ShufflePlayersDepedencyKey.self] = newValue }
    }
}

public struct ShufflePlayers {
    private let shuffle: ([Player.State]) -> [Player.State]

    static let live = Self { $0.shuffled() }
    static let test = Self {
        XCTFail(#"Unimplemented: @Dependency(\.shufflePlayers)"#)
        return $0.shuffled()
    }
    public static let alphabeticallySorted = Self { $0.sorted(by: { $0.name > $1.name }) }

    public func callAsFunction(players: [Player.State]) -> [Player.State] {
        shuffle(players)
    }
}
