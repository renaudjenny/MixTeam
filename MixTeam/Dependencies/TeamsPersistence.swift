import Dependencies
import Foundation
import XCTestDynamicOverlay

private let teamsKey = "teams"

private struct SaveTeamsDependencyKey: DependencyKey {
    static var liveValue = { (teams: [Team.State]) in
        guard let data = try? JSONEncoder().encode(teams) else { return }
        UserDefaults.standard.set(data, forKey: teamsKey)
    }
    static var testValue: ([Team.State]) -> Void = XCTUnimplemented("Save Teams non implemented")
}
extension DependencyValues {
    var saveTeams: ([Team.State]) -> Void {
        get { self[SaveTeamsDependencyKey.self] }
        set { self[SaveTeamsDependencyKey.self] = newValue }
    }
}

private struct LoadTeamsDependencyKey: DependencyKey {
    static var liveValue: [Team.State] {
        guard let data = UserDefaults.standard.data(forKey: teamsKey) else {
            return .example
        }
        return (try? JSONDecoder().decode([Team.State].self, from: data)) ?? .example
    }
    static var testValue: [Team.State] {
        XCTFail("Load Teams non implemented")
        return []
    }
}
extension DependencyValues {
    var loadedTeams: [Team.State] {
        get { self[LoadTeamsDependencyKey.self] }
        set { self[LoadTeamsDependencyKey.self] = newValue }
    }
}
