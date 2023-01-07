import ComposableArchitecture
import RenaudJennyAboutView
import SwiftUI

struct Settings: ReducerProtocol {
    struct State: Equatable {

    }

    enum Action: Equatable {

    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {

        }
    }
}

struct SettingsView: View {
    let store: StoreOf<Settings>
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        aboutView
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
    }

    private var aboutView: some View {
        RenaudJennyAboutView.AboutView(appId: "id1526493495", isInModal: true) {
            Image(uiImage: #imageLiteral(resourceName: "Logo"))
                .cornerRadius(16)
                .padding()
                .padding(.top)
                .shadow(radius: 5)
        } background: {
            MTColor.aluminium.backgroundColor(scheme: colorScheme)
                .dashedCardStyle(color: MTColor.aluminium)
        }
    }
}
