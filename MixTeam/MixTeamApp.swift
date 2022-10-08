import ComposableArchitecture
import SwiftUI

@main
struct MixTeamApp: SwiftUI.App {
    @StateObject var teamsStore = TeamsStore()

    var body: some Scene {
        WindowGroup {
            AppView(store: .live).environmentObject(teamsStore)
        }
    }
}

extension StoreOf<App> {
    static var live: StoreOf<App> {
        Store(initialState: App.State(), reducer: App())
    }
}
