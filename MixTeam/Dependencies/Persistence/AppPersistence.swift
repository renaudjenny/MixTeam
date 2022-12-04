import Dependencies
import Foundation
import XCTestDynamicOverlay

struct AppPersistence {
    private static var cache: App.State?
    private static let appFileName = "MixTeamAppV2_0_0"

    var team = TeamPersistence()
    var standing = StandingPersistence()

    var load: () async throws -> App.State = {
        if let cache { return cache }
        // TODO: manage migration
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(appFileName, conformingTo: .json))
        else { return .example }
        return try JSONDecoder().decode(App.State.self, from: data)
    }
    var save: (App.State) async throws -> Void = { state in
        cache = state
        let data = try JSONEncoder().encode(state)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(appFileName, conformingTo: .json))
    }
}

extension App.State {
    static var example: Self {
        App.State(standing: .example, teams: .example)
    }
}

private struct AppPersistenceDepedencyKey: DependencyKey {
    static var liveValue = { AppPersistence() }
    static var testValue: () -> AppPersistence = XCTUnimplemented("App Persistence non implemented")
}

extension DependencyValues {
    var appPersistence: () -> AppPersistence {
        get { self[AppPersistenceDepedencyKey.self] }
        set { self[AppPersistenceDepedencyKey.self] = newValue }
    }
}
