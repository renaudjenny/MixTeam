import Assets
import Dependencies
import Foundation
import IdentifiedCollections
import XCTestDynamicOverlay

private struct MigrationV2toV3 {
    private let team: IdentifiedArrayOf<Team>
    private let player: IdentifiedArrayOf<Player>
    private let scores: Scores

    @Dependency(\.teamPersistence) var teamPersistence
    @Dependency(\.playerPersistence) var playerPersistence
    @Dependency(\.scoresPersistence) var scoresPersistence

    init?() {
        let teamsData = UserDefaults.standard.data(forKey: "teams")
        let teams = teamsData.flatMap { (try? JSONDecoder().decode([DprTeam].self, from: $0)) }

        let roundsData = UserDefaults.standard.string(forKey: "Scores.rounds")?.data(using: .utf8)
        let rounds = roundsData.flatMap { (try? JSONDecoder().decode([DprRound].self, from: $0)) }

        let archivedTeams: [Team] = (rounds?.flatMap(\.scores).map(\.team) ?? [])
            .filter { !(teams?.map(\.id).contains($0.id) ?? false) }
            .map {
                var team = $0.state.team
                team.isArchived = true
                return team
            }

        if let teams, let rounds {
            team = IdentifiedArrayOf(uniqueElements: teams.dropFirst().map(\.state).map(\.team)) + archivedTeams
            player = IdentifiedArrayOf(uniqueElements: teams.map(\.state).flatMap(\.players))
            let rounds: IdentifiedArrayOf<Round> = IdentifiedArrayOf(
                uniqueElements: Self.roundStates(rounds: rounds)
            )
            scores = Scores(rounds: rounds)
        } else if let teams {
            team = IdentifiedArrayOf(uniqueElements: teams.dropFirst().map(\.state).map(\.team))
            player = IdentifiedArrayOf(uniqueElements: teams.map(\.state).flatMap(\.players))
            scores = Scores(rounds: [])
        } else {
            return nil
        }
    }

    func migrate() async throws {
        try await teamPersistence.save(team)
        try await playerPersistence.save(player)
        try await scoresPersistence.save(scores)

        UserDefaults.standard.removeObject(forKey: "teams")
        UserDefaults.standard.removeObject(forKey: "Scores.rounds")
    }
}

extension MigrationV2toV3 {
    private struct DprPlayer: Codable, Identifiable, Hashable {
        var id = UUID()
        var name: String = ""
        var imageIdentifier: ImageIdentifier
    }

    private struct DprTeam: Codable, Identifiable, Hashable {
        var id = UUID()
        var name: String = ""
        var colorIdentifier: ColorIdentifier = .gray
        var imageIdentifier: ImageIdentifier = .unknown
        var players: [DprPlayer] = []

        var state: (team: Team, players: IdentifiedArrayOf<Player>) {
            (
                team: Team(
                    id: id,
                    name: name,
                    color: colorIdentifier.mtColor,
                    image: imageIdentifier.mtImage,
                    playerIDs: players.map(\.id),
                    isArchived: false
                ),
                players: IdentifiedArrayOf(uniqueElements: players.map { Player(
                    id: $0.id,
                    name: $0.name,
                    image: $0.imageIdentifier.mtImage
                )})
            )
        }
    }

    private struct DprRound: Identifiable, Codable, Hashable {
        var name: String
        var scores: [DprScore]
        var id = UUID()
    }

    private struct DprScore: Identifiable, Codable, Hashable {
        var team: DprTeam
        var points: Int
        var id: DprTeam.ID { team.id }
    }

    private static func roundStates(rounds: [DprRound]) -> [Round] {
        rounds.reduce([]) { result, round in
            let state = Round(
                id: round.id,
                name: round.name,
                scores: IdentifiedArrayOf(uniqueElements: round.scores.map { score in Score(
                    id: UUID(),
                    teamID: score.team.id,
                    points: score.points
                ) })
            )

            return result + [state]
        }
    }
}

private enum ColorIdentifier: String, Codable {
    case yellow
    case orange
    case red
    case pink
    case purple
    case blue
    case green
    case gray

    var mtColor: MTColor {
        switch self {
        case .yellow: return .leather
        case .orange: return .peach
        case .red: return .strawberry
        case .pink: return .duck
        case .purple: return .lilac
        case .blue: return .bluejeans
        case .green: return .conifer
        case .gray: return .aluminium
        }
    }
}

private enum ImageIdentifier: String, Codable {
    case elephant = "elephant"
    case koala = "koala"
    case panda = "panda"
    case octopus = "octopus"
    case lion = "lion"
    case hippo = "hippo"

    case girl = "girl"
    case woman = "woman"
    case jack = "jack"
    case santa = "santa"
    case clown = "clown"
    case pirate = "pirate"

    case unknown = ""

    var mtImage: MTImage {
        switch self {
        case .elephant: return .elephant
        case .koala: return .koala
        case .panda: return .panda
        case .octopus: return .octopus
        case .lion: return .lion
        case .hippo: return .hippo
        case .girl: return .amelie
        case .woman: return .lara
        case .jack: return .jack
        case .santa: return .santa
        case .clown: return .clown
        case .pirate: return .pirate
        case .unknown: return .unknown
        }
    }
}

public struct Migration {
    public var v2toV3: () async throws -> Void
    public var v3_0toV3_1: () async throws -> Void
}

public extension Migration {
    static let live = Self(
        v2toV3: { try await MigrationV2toV3()?.migrate() },
        v3_0toV3_1: { try await MigrationV3_0toV3_1()?.migrate() }
    )
    static let test = Self(
        v2toV3: unimplemented("Migration.v2toV3"),
        v3_0toV3_1: unimplemented("Migration.v3_0toV3_1")
    )
    static let preview = Self(
        v2toV3: {},
        v3_0toV3_1: {}
    )
}

private enum MigrationDependencyKey: DependencyKey {
    static let liveValue = Migration.live
    static let testValue = Migration.test
    static let previewValue = Migration.preview
}

public extension DependencyValues {
    var migration: Migration {
        get { self[MigrationDependencyKey.self] }
        set { self[MigrationDependencyKey.self] = newValue }
    }
}
