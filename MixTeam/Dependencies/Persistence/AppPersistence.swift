import Dependencies
import Foundation
import XCTestDynamicOverlay

struct AppPersistence {
    private static var cache: App.State?
    private static var saveHandler: ((App.State) -> Void)?
    private static let appFileName = "MixTeamAppV2_0_0"

    var team = TeamPersistence()
    var standing = StandingPersistence()
    var player = PlayerPersistence()

    var app: () -> AsyncThrowingStream<App.State, Error> = {
        AsyncThrowingStream { continuation in
            saveHandler = { continuation.yield($0) }
            Task {
                if let cache {
                    continuation.yield(cache)
                    return
                }
                // TODO: manage migration
                guard
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                    let data = try? Data(contentsOf: url.appendingPathComponent(appFileName, conformingTo: .json))
                else {
                    do {
                        continuation.yield(try await AppPersistence().persistAndReturnExample())
                    } catch {
                        continuation.finish(throwing: error)
                    }
                    return
                }

                #if DEBUG
                print("Document folder: \(url)")
                #endif

                do {
                    continuation.yield(try JSONDecoder().decode(App.State.self, from: data))
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    var save: (App.State) async throws -> Void = { state in
        cache = state
        let data = try JSONEncoder().encode(state)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(appFileName, conformingTo: .json))
        saveHandler?(state)
    }

    private func persistAndReturnExample() async throws -> App.State {
        let appPersistence = AppPersistence()
        try await appPersistence.save(.example)
        try await appPersistence.team.save(.example)
        try await appPersistence.standing.save(.example)
        try await appPersistence.player.save(.example)
        return .example
    }
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
