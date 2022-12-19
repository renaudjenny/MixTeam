import Dependencies
import XCTestDynamicOverlay

struct ShufflePlayersDepedencyKey: DependencyKey {
    static let liveValue: ShufflePlayers = .live
    static let testValue: ShufflePlayers = .test
    static let previewValue: ShufflePlayers = .alphabeticallySorted
}
extension DependencyValues {
    var shufflePlayers: ShufflePlayers {
        get { self[ShufflePlayersDepedencyKey.self] }
        set { self[ShufflePlayersDepedencyKey.self] = newValue }
    }
}

struct ShufflePlayers {
    private let shuffle: ([Player.State.ID]) -> [Player.State.ID]

    static let live = Self { $0.shuffled() }
    static let test = Self {
        XCTFail(#"Unimplemented: @Dependency(\.shufflePlayers)"#)
        return $0.shuffled()
    }
    static let alphabeticallySorted = Self { $0.sorted(by: { $0.uuidString > $1.uuidString }) }

    func callAsFunction(playerIDs: [Player.State.ID]) -> [Player.State.ID] {
        shuffle(playerIDs)
    }
}
