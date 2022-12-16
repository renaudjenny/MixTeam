import Dependencies
import Foundation
import IdentifiedCollections
import XCTestDynamicOverlay

private struct Persistence {
    private let appFileName = "MixTeamAppV2_0_0"

    var team = TeamPersistence()
    var standing = StandingPersistence()
    var player = PlayerPersistence()

    var saveHandler: ((App.State) -> Void)?
    private var cache: App.State?

    mutating func load() async throws -> App.State {
        if let migratedData = try await migrateIfNeeded() { return migratedData }

        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(appFileName, conformingTo: .json))
        else { return try await persistAndReturnExample() }

        #if DEBUG
        print("Document folder: \(url)")
        #endif

        return try JSONDecoder().decode(App.State.self, from: data)
    }

    mutating func save(_ state: App.State) async throws {
        cache = state
        saveHandler?(state)
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

    private mutating func migrateIfNeeded() async throws -> App.State? {
        guard let migratedData,
              case let .loaded(standingPlayers) = migratedData.standing,
              case let .loaded(teams) = migratedData.teams
        else { return nil }
        try await save(migratedData)
        try await team.save(teams)
        try await standing.save(Standing.Persistence(playerIDs: standingPlayers.map(\.id)))
        let teamsPlayers: [Player.State] = teams.map(\.players).flatMap {
            guard case let .loaded(players) = $0 else { return IdentifiedArrayOf<Player.State>(uniqueElements: []) }
            return players
        }
        try await player.save(teamsPlayers + standingPlayers)
        UserDefaults.standard.removeObject(forKey: "teams")
        UserDefaults.standard.removeObject(forKey: "Scores.rounds")
        return migratedData
    }
}

struct AppPersistence {
    private static var persistence = Persistence()
    private static var stream: AsyncThrowingStream<App.State, Error> {
        AsyncThrowingStream { continuation in persistence.saveHandler = { continuation.yield($0) } }
    }

    var team = persistence.team
    var standing = persistence.standing
    var player = persistence.player

    var stream: () -> AsyncThrowingStream<App.State, Error> = { stream }
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
        appPersistence.stream = unimplemented("App Persistence stream unimplemented")
        appPersistence.load = unimplemented("App Persistence load unimplemented")
        appPersistence.save = unimplemented("App Persistence save unimplemented")
        appPersistence.team.stream = unimplemented("Team Persistence stream unimplemented")
        appPersistence.team.load = unimplemented("Team Persistence load unimplemented")
        appPersistence.team.save = unimplemented("Team Persistence save unimplemented")
        appPersistence.standing.load = unimplemented("Standing Persistence load unimplemented")
        appPersistence.standing.save = unimplemented("Standing Persistence save unimplemented")
        appPersistence.player.stream = unimplemented("Standing Persistence stream unimplemented")
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
