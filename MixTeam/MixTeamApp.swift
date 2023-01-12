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
            AppView(store: .live)
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
    #endif
}
