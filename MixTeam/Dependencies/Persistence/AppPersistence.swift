import AsyncAlgorithms
import Dependencies
import Foundation
import IdentifiedCollections
import XCTestDynamicOverlay

private struct Persistence {
    private let appFileName = "MixTeamAppV2_0_0"

    var team = TeamPersistence()
    var standing = StandingPersistence()
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

    private mutating func persistAndReturnExample() async throws -> App.State {
        try await save(.example)
        try await team.save(.example)
        try await standing.save(.example)
        try await player.save(.example)
        return .example
    }

    private mutating func migrateIfNeeded() async throws {
        guard let migratedData,
              case let .loaded(standingPlayers) = migratedData.standing.players,
              case let .loaded(teams) = migratedData.teams
        else { return }
        try await save(migratedData)
        try await team.save(teams)
        try await standing.save(migratedData.standing)
        let teamsPlayers: [Player.State] = teams.map(\.players).flatMap {
            guard case let .loaded(players) = $0 else { return IdentifiedArrayOf<Player.State>(uniqueElements: []) }
            return players
        }
        try await player.save(teamsPlayers + standingPlayers)
        UserDefaults.standard.removeObject(forKey: "teams")
        UserDefaults.standard.removeObject(forKey: "Scores.rounds")
        value = migratedData
    }
}

struct AppPersistence {
    private static var persistence = Persistence()

    var team = persistence.team
    var standing = persistence.standing
    var player = persistence.player

    var channel: () -> AsyncChannel<App.State> = { persistence.channel }
    var load: () async throws -> App.State = { try await persistence.load() }
    var save: (App.State) async throws -> Void = { try await persistence.save($0) }
}

extension App.State {
    static var example: Self {
        let teams: IdentifiedArrayOf<Team.State> = .example
        return Self(teamIDs: teams.map(\.id), standing: .example, teams: .loaded(teams))
    }
}

private struct AppPersistenceDepedencyKey: DependencyKey {
    static var liveValue = AppPersistence()
    static var testValue: AppPersistence = {
        var appPersistence = AppPersistence()
        appPersistence.channel = unimplemented("App Persistence channel unimplemented")
        appPersistence.load = unimplemented("App Persistence load unimplemented")
        appPersistence.save = unimplemented("App Persistence save unimplemented")
        appPersistence.team.channel = unimplemented("Team Persistence channel unimplemented")
        appPersistence.team.load = unimplemented("Team Persistence load unimplemented")
        appPersistence.team.save = unimplemented("Team Persistence save unimplemented")
        appPersistence.standing.load = unimplemented("Standing Persistence load unimplemented")
        appPersistence.standing.save = unimplemented("Standing Persistence save unimplemented")
        appPersistence.player.publisher = unimplemented("Player Persistence publisher unimplemented")
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
