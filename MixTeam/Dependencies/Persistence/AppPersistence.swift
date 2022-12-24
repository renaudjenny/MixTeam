import AsyncAlgorithms
import Dependencies
import Foundation
import IdentifiedCollections
import XCTestDynamicOverlay

private struct Persistence {
    private let appFileName = "MixTeamAppV2_0_0"

    var team = TeamPersistence()
    var player = PlayerPersistence()

    var value: App.State?

    mutating func load() async throws -> App.State {
        try await migrateIfNeeded()
        if let value { return try await inflated(value: value) }

        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(appFileName, conformingTo: .json))
        else { return try await persistAndReturnExample() }

        #if DEBUG
        print("Document folder: \(url)")
        #endif

        let decodedValue = try JSONDecoder().decode(App.State.self, from: data)
        let inflatedValue = try await inflated(value: decodedValue)
        value = inflatedValue
        return inflatedValue
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

    private func inflated(value: App.State) async throws -> App.State {
        var value = value
        var teams = try await team.load()
        let players = try await player.load()

        teams = IdentifiedArrayOf(uniqueElements: value.teams.compactMap {
            guard var team = teams[id: $0.id] else { return nil }
            team.players = IdentifiedArrayOf(uniqueElements: team.players.compactMap {
                var player = players[id: $0.id]
                player?.isStanding = false
                player?.color = team.color
                return  player
            })
            return team
        })

        let appTeamIDs = value.teams.map(\.id)
        value.teams = teams.filter { appTeamIDs.contains($0.id) }
        value.standing.players = IdentifiedArrayOf(uniqueElements: value.standing.players.compactMap {
            var player = players[id: $0.id]
            player?.isStanding = true
            return player
        })

        value.scores.teams = teams
        value.scores.rounds = IdentifiedArrayOf(uniqueElements: value.scores.rounds.map {
            var round = $0
            round.scores = IdentifiedArray(uniqueElements: round.scores.compactMap {
                guard let team = teams[id: $0.team.id] else { return nil }
                var score = $0
                score.team = team
                return score
            })
            return round
        })
        return value
    }
}

struct AppPersistence {
    private static var persistence = Persistence()

    var team = persistence.team
    var player = persistence.player

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
        case scores
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let teamIDs = try container.decode([Team.State.ID].self, forKey: .teamIDs)
        teams = IdentifiedArrayOf(uniqueElements: teamIDs.map { Team.State(id: $0) })
        standing = try container.decode(Standing.State.self, forKey: .standing)
        scores = try container.decode(Scores.State.self, forKey: .scores)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(teams.map(\.id), forKey: .teamIDs)
        try container.encode(standing, forKey: .standing)
        try container.encode(scores, forKey: .scores)
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
