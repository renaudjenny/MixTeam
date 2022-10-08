import Dependencies
import Foundation
import XCTestDynamicOverlay

private let appStateKey = "app-state"

private struct PersistenceSaveDependencyKey: DependencyKey {
    static var liveValue = { (state: App.State) in
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: appStateKey)
    }
    static var testValue: (App.State) -> Void = XCTUnimplemented("Save App State non implemented")
}
extension DependencyValues {
    var save: (App.State) -> Void {
        get { self[PersistenceSaveDependencyKey.self] }
        set { self[PersistenceSaveDependencyKey.self] = newValue }
    }
}

private struct PersistenceLoadDependencyKey: DependencyKey {
    static var liveValue: App.State {
        guard let data = UserDefaults.standard.data(forKey: appStateKey) else {
            return .example
        }
        return (try? JSONDecoder().decode(App.State.self, from: data)) ?? .example
    }
    static var testValue: App.State {
        XCTFail("Load App State non implemented")
        return App.State()
    }
}
extension DependencyValues {
    var loaded: App.State {
        get { self[PersistenceLoadDependencyKey.self] }
        set { self[PersistenceLoadDependencyKey.self] = newValue }
    }
}
