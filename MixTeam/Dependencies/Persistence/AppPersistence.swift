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
        guard let migratedData, case let .loaded(standingPlayers) = migratedData.standing.players else { return }
        let teams = IdentifiedArrayOf(uniqueElements: migratedData.teamRows.compactMap { teamRow -> Team.State? in
            if case let .loaded(team) = teamRow.row { return team } else { return nil }
        })
        
        try await save(migratedData)
        try await team.save(teams)
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
    var player = persistence.player

    var channel: () -> AsyncChannel<App.State> = { persistence.channel }
    var load: () async throws -> App.State = { try await persistence.load() }
    var save: (App.State) async throws -> Void = { try await persistence.save($0) }
    var saveStanding: (Standing.State) async throws -> Void = { try await persistence.save(standing: $0) }
}

extension App.State {
    static var example: Self {
        let teams: IdentifiedArrayOf<Team.State> = .example
        let teamRows = IdentifiedArrayOf(uniqueElements: teams.map(\.id).map { TeamRow1.State(id: $0) })
        return Self(teamRows: teamRows, standing: .example)
    }
}

extension Standing.State {
    static var example: Self {
        let players = IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Player.State>.example.prefix(2).map {
            var player = $0
            player.isStanding = true
            return player
        })
        return Self(playerIDs: players.map(\.id), players: .loaded(players))
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
