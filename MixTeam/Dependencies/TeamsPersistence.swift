import Dependencies
import Foundation
import XCTestDynamicOverlay

private let teamsKey = "teams"

private struct SaveTeamsDependencyKey: DependencyKey {
    static var liveValue = { (teams: [Team]) in
        guard let data = try? JSONEncoder().encode(teams) else { return }
        UserDefaults.standard.set(data, forKey: teamsKey)
    }
    static var testValue: ([Team]) -> Void = XCTUnimplemented("Save Teams non implemented")
}
extension DependencyValues {
    var saveTeams: ([Team]) -> Void {
        get { self[SaveTeamsDependencyKey.self] }
        set { self[SaveTeamsDependencyKey.self] = newValue }
    }
}

private struct LoadTeamsDependencyKey: DependencyKey {
    static var liveValue: [Team] {
        guard let data = UserDefaults.standard.data(forKey: teamsKey) else {
            return .exampleTeam
        }
        return (try? JSONDecoder().decode([Team].self, from: data)) ?? .exampleTeam
    }
    static var testValue: [Team] {
        XCTFail("Load Teams non implemented")
        return []
    }
}
extension DependencyValues {
    var loadedTeams: [Team] {
        get { self[LoadTeamsDependencyKey.self] }
        set { self[LoadTeamsDependencyKey.self] = newValue }
    }
}
