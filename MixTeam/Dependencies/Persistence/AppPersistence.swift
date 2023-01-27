import Dependencies
import Foundation
import IdentifiedCollections
import XCTestDynamicOverlay

private struct Persistence {
    private let appFileName = "MixTeamAppV3_0_0"

    @Dependency(\.teamPersistence) var team
    @Dependency(\.playerPersistence) var player

    var value: AppData.State?

    mutating func load() async throws -> AppData.State {
        try await migrateIfNeeded()
        if let value { return try await inflated(value: value) }

        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(appFileName, conformingTo: .json))
        else { return try await persistAndReturnExample() }

        #if DEBUG
        print("Document folder: \(url)")
        #endif

        let decodedValue = try JSONDecoder().decode(AppData.State.self, from: data)
        let inflatedValue = try await inflated(value: decodedValue)
        value = inflatedValue
        return inflatedValue
    }

    mutating func save(_ state: AppData.State) async throws {
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

    mutating func save(composition: CompositionLegacy.State) async throws {
        value?.composition = composition
        if let value {
            try await save(value)
        }
    }

    private mutating func persistAndReturnExample() async throws -> AppData.State {
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

    private func inflated(value: AppData.State) async throws -> AppData.State {
        var value = value
        let teams = try await team.load()
        let players = try await player.load()

        value.teams = IdentifiedArrayOf(uniqueElements: value.teams.compactMap {
            guard var team = teams[id: $0.id] else { return nil }
            team.players = IdentifiedArrayOf(uniqueElements: team.players.compactMap {
                var player = players[id: $0.id]
                player?.color = team.color
                return  player
            })
            return team
        })

        value.composition.teams = IdentifiedArrayOf(
            uniqueElements: value.composition.teams.compactMap { value.teams[id: $0.id] }
        )
        value.composition.standing.players = IdentifiedArrayOf(
            uniqueElements: value.composition.standing.players.compactMap { players[id: $0.id] }
        )

        return value
    }
}

struct AppPersistence {
    private static var persistence = Persistence()

    var team = persistence.team
    var player = persistence.player

    var load: () async throws -> AppData.State = { try await persistence.load() }
    var save: (AppData.State) async throws -> Void = { try await persistence.save($0) }
    var saveStanding: (Standing.State) async throws -> Void = { try await persistence.save(standing: $0) }
    var saveComposition: (CompositionLegacy.State) async throws -> Void = { try await persistence.save(composition: $0) }
}

extension AppData.State {
    static var example: Self {
        Self(teams: .example, composition: .example)
    }
}

extension AppData.State: Codable {
    enum CodingKeys: CodingKey {
        case teamIDs
        case composition
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let teamIDs = try container.decode([Team.State.ID].self, forKey: .teamIDs)
        teams = IdentifiedArrayOf(uniqueElements: teamIDs.map { Team.State(id: $0) })
        composition = try container.decode(CompositionLegacy.State.self, forKey: .composition)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(teams.map(\.id), forKey: .teamIDs)
        try container.encode(composition, forKey: .composition)
    }
}

private struct AppPersistenceDepedencyKey: DependencyKey {
    static var liveValue = AppPersistence()
    static var testValue: AppPersistence = {
        var appPersistence = AppPersistence()
        appPersistence.load = unimplemented("App Persistence load unimplemented")
        appPersistence.save = unimplemented("App Persistence save unimplemented")
        appPersistence.saveStanding = unimplemented("App Persistence save standing unimplemented")
        appPersistence.saveComposition = unimplemented("App Persistence saveComposition unimplemented")
        return appPersistence
    }()
    #if DEBUG
    static var previewValue: AppPersistence = { () -> AppPersistence in
        var appPersistence = AppPersistence()
        appPersistence.load = { .example }
        appPersistence.save = { _ in print("##### AppData saved") }
        appPersistence.saveStanding = { _ in print("##### Standing saved") }
        appPersistence.saveComposition = { _ in print("##### Composition saved") }
        return appPersistence
    }()
    #endif
}

extension DependencyValues {
    var appPersistence: AppPersistence {
        get { self[AppPersistenceDepedencyKey.self] }
        set { self[AppPersistenceDepedencyKey.self] = newValue }
    }
}
