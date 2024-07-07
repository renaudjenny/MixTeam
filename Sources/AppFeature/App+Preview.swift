import ComposableArchitecture
import PersistenceCore

public extension Store where State == App.State, Action == App.Action {
    static var live: Store<App.State, App.Action> {
        Store(initialState: App.State()) { App() }
    }

    #if DEBUG
    static var preview: Store<App.State, App.Action> {
        Store(initialState: .example) {
            App().dependency(\.playerPersistence, .preview)
        }
    }

    static var withError: Store<App.State, App.Action> {
        Store(initialState: App.State()) {
            App()
                .dependency(\.playerPersistence, .preview)
                .dependency(\.teamPersistence.load, {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    throw PersistenceError.notFound
                })
        }
    }
    #endif
}
