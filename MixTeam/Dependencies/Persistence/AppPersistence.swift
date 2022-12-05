import Dependencies
import Foundation
import XCTestDynamicOverlay

struct AppPersistence {
    private static var cache: App.State?
    private static let appFileName = "MixTeamAppV2_0_0"

    var team = TeamPersistence()
    var standing = StandingPersistence()
    var player = PlayerPersistence()

    var load: () async throws -> App.State = {
        if let cache { return cache }
        // TODO: manage migration
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(appFileName, conformingTo: .json))
        else { return try await AppPersistence().persistAndReturnExample() }

        #if DEBUG
        print("Document folder: \(url)")
        #endif

        return try JSONDecoder().decode(App.State.self, from: data)
    }
    var save: (App.State) async throws -> Void = { state in
        cache = state
        let data = try JSONEncoder().encode(state)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(appFileName, conformingTo: .json))
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
        appPersistence.load = XCTUnimplemented("App Persistence load non implemented")
        appPersistence.save = XCTUnimplemented("App Persistence save non implemented")
        appPersistence.team.load = XCTUnimplemented("Team Persistence load non implemented")
        appPersistence.team.save = XCTUnimplemented("Team Persistence save non implemented")
        appPersistence.standing.load = XCTUnimplemented("Standing Persistence load non implemented")
        appPersistence.standing.save = XCTUnimplemented("Standing Persistence save non implemented")
        appPersistence.player.load = XCTUnimplemented("Player Persistence load non implemented")
        appPersistence.player.save = XCTUnimplemented("Player Persistence save non implemented")
        return appPersistence
    }()
}

extension DependencyValues {
    var appPersistence: AppPersistence {
        get { self[AppPersistenceDepedencyKey.self] }
        set { self[AppPersistenceDepedencyKey.self] = newValue }
    }
}
