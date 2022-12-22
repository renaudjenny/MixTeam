import AsyncAlgorithms
import Dependencies
import Foundation
import IdentifiedCollections
import XCTestDynamicOverlay

private struct Persistence {
    private let appFileName = "MixTeamAppV2_0_0"

    var team = TeamPersistence()
    var player = PlayerPersistence()

    let channel = AsyncChannel<App.State>()
    var value: App.State? {
        didSet {
            if let value {
                Task { [channel, value] in await channel.send(value) }
            }
        }
    }

    mutating func load() async throws -> App.State {
        try await migrateIfNeeded()
        if let value { return value }

        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(appFileName, conformingTo: .json))
        else { return try await persistAndReturnExample() }

        #if DEBUG
        print("Document folder: \(url)")
        #endif

        let decodedValue = try JSONDecoder().decode(App.State.self, from: data)
        value = decodedValue
        return decodedValue
    }

    mutating func save(_ state: App.State) async throws {
        value = state
        let data = try JSONEncoder().encode(state)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(appFileName, conformingTo: .json))
    }

    mutating func save(standing: Standing.State) async throws {
        value?.standing = standing
        if let value {
            try await save(value)
        }
    }

    private mutating func persistAndReturnExample() async throws -> App.State {
        try await save(.example)
        try await team.save(.example)
        try await player.save(.example)
        return .example
    }

    private mutating func migrateIfNeeded() async throws {
        guard let migratedData else { return }
        try await save(migratedData)
        try await team.save(migratedData.teams)
        let teamsPlayers: [Player.State] = migratedData.teams.flatMap(\.players)
        try await player.save(teamsPlayers + migratedData.standing.players)
        UserDefaults.standard.removeObject(forKey: "teams")
        UserDefaults.standard.removeObject(forKey: "Scores.rounds")
        value = migratedData
    }
}

struct AppPersistence {
    private static var persistence = Persistence()

    var team = persistence.team
    var player = persistence.player

    var channel: () -> AsyncChannel<App.State> = { persistence.channel }
    var load: () async throws -> App.State = { try await persistence.load() }
    var save: (App.State) async throws -> Void = { try await persistence.save($0) }
    var saveStanding: (Standing.State) async throws -> Void = { try await persistence.save(standing: $0) }
}

extension App.State {
    static var example: Self {
        Self(teams: .example, standing: .example)
    }
}

extension App.State: Codable {
    enum CodingKeys: CodingKey {
        case teamIDs
        case standing
        case _scores
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let teamIDs = try container.decode([Team.State.ID].self, forKey: .teamIDs)
        teams = IdentifiedArrayOf(uniqueElements: teamIDs.map { Team.State(id: $0) })
        standing = try container.decode(Standing.State.self, forKey: .standing)
        _scores = try container.decode(Scores.State.self, forKey: ._scores)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(teams.map(\.id), forKey: .teamIDs)
        try container.encode(standing, forKey: .standing)
        try container.encode(_scores, forKey: ._scores)
    }
}

extension Standing.State {
    static var example: Self {
        let players = IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Player.State>.example.prefix(2).map {
            var player = $0
            player.isStanding = true
            return player
        })
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

private struct AppPersistenceDepedencyKey: DependencyKey {
    static var liveValue = AppPersistence()
    static var testValue: AppPersistence = {
        var appPersistence = AppPersistence()
        appPersistence.channel = unimplemented("App Persistence channel unimplemented")
        appPersistence.load = unimplemented("App Persistence load unimplemented")
        appPersistence.save = unimplemented("App Persistence save unimplemented")
        appPersistence.saveStanding = unimplemented("App Persistence save standing unimplemented")
        appPersistence.team.channel = unimplemented("Team Persistence channel unimplemented")
        appPersistence.team.load = unimplemented("Team Persistence load unimplemented")
        appPersistence.team.save = unimplemented("Team Persistence save unimplemented")
        appPersistence.player.channel = unimplemented("Player Persistence channel unimplemented")
        appPersistence.player.load = unimplemented("Player Persistence load unimplemented")
        appPersistence.player.save = unimplemented("Player Persistence save unimplemented")
        return appPersistence
    }()
}

extension DependencyValues {
    var appPersistence: AppPersistence {
        get { self[AppPersistenceDepedencyKey.self] }
        set { self[AppPersistenceDepedencyKey.self] = newValue }
    }
}
