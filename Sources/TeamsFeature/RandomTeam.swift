import Assets
import Dependencies
import Foundation
import XCTestDynamicOverlay

struct RandomTeamDepedencyKey: DependencyKey {
    static let liveValue: RandomTeam = .live
    static let testValue: RandomTeam = .test
    static let previewValue: RandomTeam = .strawberryBunny
}
public extension DependencyValues {
    var randomTeam: RandomTeam {
        get { self[RandomTeamDepedencyKey.self] }
        set { self[RandomTeamDepedencyKey.self] = newValue }
    }
}

public struct RandomTeam {
    private let random: () -> Team.State

    static let live = Self {
        @Dependency(\.uuid) var uuid

        let image = MTImage.teams.randomElement() ?? .koala
        let color = MTColor.allCases.filter({ $0 != .aluminium }).randomElement() ?? .aluminium
        let name = "\(color.rawValue) \(image.rawValue)".localizedCapitalized
        return Team.State(id: uuid(), name: name, color: color, image: image)
    }
    static let test = Self {
        XCTFail(#"Unimplemented: @Dependency(\.shufflePlayers)"#)
        return live.random()
    }
    public static let strawberryBunny = Self {
        @Dependency(\.uuid) var uuid

        let image: MTImage = .bunny
        let color: MTColor = .strawberry
        let name = "\(color.rawValue) \(image.rawValue)".localizedCapitalized
        return Team.State(id: uuid(), name: name, color: color, image: image)
    }

    public func callAsFunction() -> Team.State {
        random()
    }
}
