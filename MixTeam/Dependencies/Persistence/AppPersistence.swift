import Dependencies
import Foundation
import IdentifiedCollections
import XCTestDynamicOverlay

private struct Persistence {
    private let appFileName = "MixTeamAppV3_0_0"

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
        value?.composition.standing = standing
        if let value {
            try await save(value)
        }
    }

    mutating func save(scores: Scores.State) async throws {
        value?.scores = scores
        if let value {
            try await save(value)
        }
    }

    mutating func save(composition: Composition.State) async throws {
        value?.composition = composition
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
        try await player.save(teamsPlayers + migratedData.composition.standing.players)
        UserDefaults.standard.removeObject(forKey: "teams")
        UserDefaults.standard.removeObject(forKey: "Scores.rounds")
        value = migratedData
    }

    private func inflated(value: App.State) async throws -> App.State {
        var value = value
        let teams = try await team.load()
        let players = try await player.load()

        value.teams = IdentifiedArrayOf(uniqueElements: value.teams.compactMap {
            guard var team = teams[id: $0.id] else { return nil }
            team.players = IdentifiedArrayOf(uniqueElements: team.players.compactMap {
                var player = players[id: $0.id]
                player?.isStanding = false
                player?.color = team.color
                return  player
            })
            return team
        })

        value.composition.teams = IdentifiedArrayOf(
            uniqueElements: value.composition.teams.compactMap { value.teams[id: $0.id] }
        )
        value.composition.standing.players = IdentifiedArrayOf(
            uniqueElements: value.composition.standing.players.compactMap {
                var player = players[id: $0.id]
                player?.isStanding = true
                return player
            }
        )

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
    var saveScores: (Scores.State) async throws -> Void = { try await persistence.save(scores: $0) }
    var saveComposition: (Composition.State) async throws -> Void = { try await persistence.save(composition: $0) }
}

extension App.State {
    static var example: Self {
        Self(teams: .example, composition: .example, scores: .example)
    }
}

extension App.State: Codable {
    enum CodingKeys: CodingKey {
        case teamIDs
        case composition
        case scores
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let teamIDs = try container.decode([Team.State.ID].self, forKey: .teamIDs)
        teams = IdentifiedArrayOf(uniqueElements: teamIDs.map { Team.State(id: $0) })
        composition = try container.decode(Composition.State.self, forKey: .composition)
        scores = try container.decode(Scores.State.self, forKey: .scores)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(teams.map(\.id), forKey: .teamIDs)
        try container.encode(composition, forKey: .composition)
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

extension Scores.State {
    static var example: Self {
        Self(teams: .example)
    }
}

extension Composition.State: Codable {
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

extension Composition.State {
    static var example: Self {
        Self(teams: .example, standing: .example)
    }
}

private struct AppPersistenceDepedencyKey: DependencyKey {
    static var liveValue = AppPersistence()
    static var testValue: AppPersistence = {
        var appPersistence = AppPersistence()
        appPersistence.load = unimplemented("App Persistence load unimplemented")
        appPersistence.save = unimplemented("App Persistence save unimplemented")
        appPersistence.saveStanding = unimplemented("App Persistence save standing unimplemented")
        appPersistence.team.load = unimplemented("Team Persistence load unimplemented")
        appPersistence.team.save = unimplemented("Team Persistence save unimplemented")
        appPersistence.team.updateOrAppend = unimplemented("Team Persistence updateOrAppend unimplemented")
        appPersistence.team.updateValues = unimplemented("Team Persistence updateValues unimplemented")
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
