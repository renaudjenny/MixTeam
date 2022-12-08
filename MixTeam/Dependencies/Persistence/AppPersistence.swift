import Dependencies
import Foundation
import XCTestDynamicOverlay
import AsyncAlgorithms

private struct Persistence {
    private let appFileName = "MixTeamAppV2_0_0"

    var team = TeamPersistence()
    var standing = StandingPersistence()
    var player = PlayerPersistence()

    var app: AsyncThrowingChannel<App.State, Error> = AsyncThrowingChannel<App.State, Error>()

    init() {
        Task { [self] in
            if let migratedData {
                try await save(migratedData)
                await app.send(migratedData)
//                UserDefaults.standard.removeObject(forKey: "teams")
//                UserDefaults.standard.removeObject(forKey: "Scores.rounds")
                return
            }

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
}

struct AppPersistence {
    private static var persistence = Persistence()

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
        appPersistence.app = XCTUnimplemented("App Persistance stream unimplemented")
        appPersistence.save = XCTUnimplemented("App Persistence save unimplemented")
        appPersistence.team.load = XCTUnimplemented("Team Persistence load unimplemented")
        appPersistence.team.save = XCTUnimplemented("Team Persistence save unimplemented")
        appPersistence.standing.load = XCTUnimplemented("Standing Persistence load unimplemented")
        appPersistence.standing.save = XCTUnimplemented("Standing Persistence save unimplemented")
        appPersistence.player.load = XCTUnimplemented("Player Persistence load unimplemented")
        appPersistence.player.save = XCTUnimplemented("Player Persistence save unimplemented")
        return appPersistence
    }()
}

extension DependencyValues {
    var appPersistence: AppPersistence {
        get { self[AppPersistenceDepedencyKey.self] }
        set { self[AppPersistenceDepedencyKey.self] = newValue }
    }
}
