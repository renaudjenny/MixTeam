import Dependencies
import Foundation
import IdentifiedCollections
import Models

// swiftlint:disable:next type_name
struct MigrationV3_0toV3_1 {
    private let team: IdentifiedArrayOf<PersistedTeam>
    private let player: IdentifiedArrayOf<PersistedPlayer>
    private let scores: PersistedScores

    private let legacyTeamFileName = "MixTeamTeamV3_0_0"
    private let legacyPlayerFileName = "MixTeamPlayerV3_0_0"
    private let legacyAppFileName = "MixTeamAppV3_0_0"

    @Dependency(\.legacyTeamPersistence) var legacyTeamPersistence
    @Dependency(\.legacyPlayerPersistence) var legacyPlayerPersistence
    @Dependency(\.legacyScoresPersistence) var legacyScoresPersistence

    init?() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return nil }

        guard let appData = try? Data(contentsOf: url.appendingPathComponent(legacyAppFileName, conformingTo: .json)),
              let playerData = try? Data(
                contentsOf: url.appendingPathComponent(legacyPlayerFileName, conformingTo: .json)
              ),
              let teamData = try? Data(contentsOf: url.appendingPathComponent(legacyTeamFileName, conformingTo: .json)),
              let app = try? JSONDecoder().decode(AppDataState.self, from: appData),
              let player = try? JSONDecoder().decode(IdentifiedArrayOf<PersistedPlayer>.self, from: playerData),
              let team = try? JSONDecoder().decode(IdentifiedArrayOf<PersistedTeam>.self, from: teamData)
        else { return nil }

        self.team = team
        self.player = player
        self.scores = app.scores
    }

    func migrate() async throws {
        try await legacyTeamPersistence.save(team)
        try await legacyPlayerPersistence.save(player)
        try await legacyScoresPersistence.save(scores)

        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }

        try FileManager.default.removeItem(at: url.appendingPathComponent(legacyAppFileName, conformingTo: .json))
        try FileManager.default.removeItem(at: url.appendingPathComponent(legacyPlayerFileName, conformingTo: .json))
        try FileManager.default.removeItem(at: url.appendingPathComponent(legacyTeamFileName, conformingTo: .json))
    }
}

private extension MigrationV3_0toV3_1 {
    struct AppDataState: Decodable {
        var scores: PersistedScores
    }
}
