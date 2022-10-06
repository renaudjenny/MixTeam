import SwiftUI

@main
struct MixTeamApp: App {
    @StateObject var teamsStore = TeamsStore()

    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(teamsStore)
        }
    }
}
