import AsyncAlgorithms
import Dependencies
import Foundation
import XCTestDynamicOverlay

private struct Persistence {
    private let appFileName = "MixTeamAppV2_0_0"

    var team = TeamPersistence()
    var standing = StandingPersistence()
    var player = PlayerPersistence()

    var app = AsyncThrowingChannel<App.State, Error>()

    init() {
        Task { [self] in
            if try await migrateIfNeeded() { return }

            guard
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                let data = try? Data(contentsOf: url.appendingPathComponent(appFileName, conformingTo: .json))
            else {
                do {
                    await app.send(try await persistAndReturnExample())
                } catch {
                    await app.fail(error)
                }
                return
            }

            #if DEBUG
            print("Document folder: \(url)")
            #endif

            do {
                await app.send(try JSONDecoder().decode(App.State.self, from: data))
            } catch {
                await app.fail(error)
            }
        }
    }

    func save(_ state: App.State) async throws {
        await app.send(state)
        let data = try JSONEncoder().encode(state)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(appFileName, conformingTo: .json))
    }

    private func persistAndReturnExample() async throws -> App.State {
        try await save(.example)
        try await team.save(.example)
        try await standing.save(.example)
        try await player.save(.example)
        return .example
    }

    private func migrateIfNeeded() async throws -> Bool {
        guard let migratedData else { return false }
        try await save(migratedData)
        try await team.save(migratedData.teams)
        try await standing.save(migratedData.standing)
        try await player.save(migratedData.teams.flatMap(\.players) + migratedData.standing.players)
        await app.send(migratedData)
        UserDefaults.standard.removeObject(forKey: "teams")
        UserDefaults.standard.removeObject(forKey: "Scores.rounds")
        return true
    }
}

struct AppPersistence {
    private static let persistence = Persistence()

    var team = persistence.team
    var standing = persistence.standing
    var player = persistence.player

    var app: () -> AsyncThrowingChannel<App.State, Error> = { persistence.app }
    var save: (App.State) async throws -> Void = persistence.save
}

extension App.State {
    static var example: Self {
        App.State(standing: .example, teams: .example)
    }
}

private struct AppPersistenceDepedencyKey: DependencyKey {
    static var liveValue = AppPersistence()
    static var testValue: AppPersistence = {
        var appPersistence = AppPersistence()
        appPersistence.app = unimplemented("App Persistance stream unimplemented")
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
