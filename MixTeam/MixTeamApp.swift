import SwiftUI

@main
struct MixTeamApp: SwiftUI.App {
    @StateObject var teamsStore = TeamsStore()

    var body: some Scene {
        WindowGroup {
            AppView().environmentObject(teamsStore)
        }
    }
}
