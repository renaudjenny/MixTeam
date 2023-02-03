import Dependencies
import Foundation
import IdentifiedCollections

// swiftlint:disable:next type_name
struct MigrationV3_0toV3_1 {
    private let team: IdentifiedArrayOf<Team.State>
    private let player: IdentifiedArrayOf<Player.State>
    private let scores: Scores.State

    private let legacyTeamFileName = "MixTeamTeamV3_0_0"
    private let legacyPlayerFileName = "MixTeamPlayerV3_0_0"
    private let legacyAppFileName = "MixTeamAppV3_0_0"

    @Dependency(\.teamPersistence) var teamPersistence
    @Dependency(\.playerPersistence) var playerPersistence
    @Dependency(\.scoresPersistence) var scoresPersistence

    init?() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return nil }

        guard let appData = try? Data(contentsOf: url.appendingPathComponent(legacyAppFileName, conformingTo: .json)),
              let playerData = try? Data(
                contentsOf: url.appendingPathComponent(legacyPlayerFileName, conformingTo: .json)
              ),
              let teamData = try? Data(contentsOf: url.appendingPathComponent(legacyTeamFileName, conformingTo: .json)),
              let app = try? JSONDecoder().decode(AppDataState.self, from: appData),
              let player = try? JSONDecoder().decode(IdentifiedArrayOf<Player.State>.self, from: playerData),
              let team = try? JSONDecoder().decode(IdentifiedArrayOf<Team.State>.self, from: teamData)
        else { return nil }

        self.team = team
        self.player = player
        self.scores = app.scores
    }

    func migrate() async throws {
        try await teamPersistence.save(team)
        try await playerPersistence.save(player)
        try await scoresPersistence.save(scores)

        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }

        try FileManager.default.removeItem(at: url.appendingPathComponent(legacyAppFileName, conformingTo: .json))
        try FileManager.default.removeItem(at: url.appendingPathComponent(legacyPlayerFileName, conformingTo: .json))
        try FileManager.default.removeItem(at: url.appendingPathComponent(legacyTeamFileName, conformingTo: .json))
    }
}

private extension MigrationV3_0toV3_1 {
    struct AppDataState: Decodable {
        var teams: IdentifiedArrayOf<Team.State>
        var composition: CompositionState
        var scores: Scores.State
    }

    struct CompositionState: Decodable {
        var teams: IdentifiedArrayOf<Team.State>
        var standing: Standing.State
    }
}
