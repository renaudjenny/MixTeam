import Dependencies
import Foundation
import IdentifiedCollections

// TODO: remove this file?
private final class Persistence {
    private let compositionFileName = "MixTeamCompositionV3_1_0"

    @Dependency(\.teamPersistence) var team
    @Dependency(\.playerPersistence) var player

    var value: CompositionLegacy.State {
        didSet { Task { try await persist(value) } }
    }

    init() throws {
        // TODO: migration from V2 & V3.0
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(compositionFileName, conformingTo: .json))
        else {
            value = .example
            return
        }

        let decodedValue = try JSONDecoder().decode(CompositionLegacy.State.self, from: data)
        value = decodedValue
    }

    func save(_ state: CompositionLegacy.State) async throws {
        value = state
    }

    private func persist(_ state: CompositionLegacy.State) async throws {
        let data = try JSONEncoder().encode(state)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(compositionFileName, conformingTo: .json))
    }

    func inflated(value: CompositionLegacy.State) async throws -> CompositionLegacy.State {
        let teams = try await team.load().filter { !$0.isArchived }
        let playersInTeams = teams.flatMap(\.players)
        let standingPlayers = try await player.load().filter { !playersInTeams.contains($0) }

        return CompositionLegacy.State(
            teams: teams,
            standing: Standing.State(players: standingPlayers)
        )
    }
}

extension Standing.State {
    static var example: Self {
        let players = IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Player.State>.example.prefix(2))
        return Self(players: players)
    }
}

extension Standing.State: Codable {
    enum CodingKeys: CodingKey {
        case playerIDs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let playerIDs = try container.decode([Player.State.ID].self, forKey: .playerIDs)
        players = IdentifiedArrayOf(uniqueElements: playerIDs.map { Player.State(id: $0) })
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(players.map(\.id), forKey: .playerIDs)
    }
}

extension CompositionLegacy.State: Codable {
    enum CodingKeys: CodingKey {
        case teamIDs
        case standing
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let teamIDs = try container.decode([Team.State.ID].self, forKey: .teamIDs)
        teams = IdentifiedArrayOf(uniqueElements: teamIDs.map { Team.State(id: $0) })
        standing = try container.decode(Standing.State.self, forKey: .standing)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(teams.map(\.id), forKey: .teamIDs)
        try container.encode(standing, forKey: .standing)
    }
}

extension CompositionLegacy.State {
    static var example: Self {
        Self(teams: .example, standing: .example)
    }
}
