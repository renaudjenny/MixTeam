import ComposableArchitecture
import RenaudJennyAboutView
import SwiftUI

struct Settings: ReducerProtocol {
    struct State: Equatable {
        var archives = Archives.State()
    }

    enum Action: Equatable {
        case archives(Archives.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.archives, action: /Action.archives) {
            Archives()
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
                NavigationLink {
                    ArchivesView(store: store.scope(state: \.archives, action: Settings.Action.archives))
                } label: {
                    Text("Archives")
                }
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
