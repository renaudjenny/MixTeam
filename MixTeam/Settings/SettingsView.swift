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
        NavigationView {
            List {
                NavigationLink { aboutView } label: { Text("About") }
            }
        }
        .tabItem {
            Label("Settings", systemImage: "gear")
        }
        .navigationViewStyle(.stack)
    }

    private var aboutView: some View {
        RenaudJennyAboutView.AboutView(appId: "id1526493495") {
            Image(uiImage: #imageLiteral(resourceName: "Logo"))
                .cornerRadius(16)
                .padding()
                .padding(.top)
                .shadow(radius: 5)
        }
    }
}
