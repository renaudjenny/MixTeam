import AppFeature
import PersistenceCore
import SwiftUI

@main
struct MixTeamApp: SwiftUI.App {

    #if DEBUG
//    init() {
//        do {
//            addV2PersistedData()
//            try addV3_0toV3_1PersistedData()
//        } catch {
//            print(error)
//        }
//    }
    #endif

    var body: some Scene {
        WindowGroup {
            AppView(store: .live)
        }
    }
}
