import ComposableArchitecture
import SwiftUI

@main
struct MixTeamApp: SwiftUI.App {
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
}
