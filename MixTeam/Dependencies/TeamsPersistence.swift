import Dependencies
import Foundation
import XCTestDynamicOverlay

private let teamsKey = "teams"

private struct SaveTeamsDependencyKey: DependencyKey {
    static var liveValue = { (teams: [DprTeam]) in
        guard let data = try? JSONEncoder().encode(teams) else { return }
        UserDefaults.standard.set(data, forKey: teamsKey)
    }
    static var testValue: ([DprTeam]) -> Void = XCTUnimplemented("Save Teams non implemented")
}
extension DependencyValues {
    var saveTeams: ([DprTeam]) -> Void {
        get { self[SaveTeamsDependencyKey.self] }
        set { self[SaveTeamsDependencyKey.self] = newValue }
    }
}

private struct LoadTeamsDependencyKey: DependencyKey {
    static var liveValue: [DprTeam] {
        guard let data = UserDefaults.standard.data(forKey: teamsKey) else {
            return .exampleTeam
        }
        return (try? JSONDecoder().decode([DprTeam].self, from: data)) ?? .exampleTeam
    }
    static var testValue: [DprTeam] {
        XCTFail("Load Teams non implemented")
        return []
    }
}
extension DependencyValues {
    var loadedTeams: [DprTeam] {
        get { self[LoadTeamsDependencyKey.self] }
        set { self[LoadTeamsDependencyKey.self] = newValue }
    }
}
