import ComposableArchitecture
import SwiftUI

@main
struct MixTeamApp: SwiftUI.App {

    #if DEBUG
    init() {
//        addV2PersistedData()
    }
    #endif

    var body: some Scene {
        WindowGroup {
            AppView(store: .withError)
        }
    }
}

extension StoreOf<App> {
    static var live: StoreOf<App> {
        Store(initialState: App.State(), reducer: App())
    }
    #if DEBUG
    static var preview: StoreOf<App> {
        Store(
            initialState: .example,
            reducer: App()
                .dependency(\.playerPersistence, .preview)
        )
    }

    static var withError: StoreOf<App> {
        Store(
            initialState: App.State(),
            reducer: App()
                .dependency(\.playerPersistence, .preview)
                .dependency(\.teamPersistence.load, {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    throw PersistenceError.notFound
                })
        )
    }
    #endif
}
