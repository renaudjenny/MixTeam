import ArchivesFeature
import ComposableArchitecture
import RenaudJennyAboutView
import SwiftUI

public struct Settings: ReducerProtocol {
    public struct State: Equatable {
        var archives: Archives.State = .loadingCard

        public init(archives: Archives.State = .loadingCard) {
            self.archives = archives
        }
    }

    public enum Action: Equatable {
        case archives(Archives.Action)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.archives, action: /Action.archives) {
            Archives()
        }
    }
}

public struct SettingsView: View {
    let store: StoreOf<Settings>
    @Environment(\.colorScheme) private var colorScheme

    public init(store: StoreOf<Settings>) {
        self.store = store
    }

    public var body: some View {
        NavigationView {
            List {
                NavigationLink { aboutView } label: { Text("About") }
                NavigationLink {
                    ArchivesView(store: store.scope(state: \.archives, action: Settings.Action.archives))
                } label: {
                    Text("Archives")
                }
            }
            .navigationTitle("Settings")
        }
        .tabItem {
            Label("Settings", systemImage: "gear")
        }
    }

    private var aboutView: some View {
        RenaudJennyAboutView.AboutView(appId: "id1526493495") {
            #if os(iOS)
            Image(uiImage: #imageLiteral(resourceName: "Logo"))
                .cornerRadius(16)
                .padding()
                .padding(.top)
                .shadow(radius: 5)
            #else
            Image(nsImage: #imageLiteral(resourceName: "Logo"))
                .cornerRadius(16)
                .padding()
                .padding(.top)
                .shadow(radius: 5)
            #endif
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: .preview)
    }
}

extension StoreOf<Settings> {
    static var preview: StoreOf<Settings> {
        StoreOf<Settings>(initialState: Settings.State(), reducer: Settings())
    }
}
#endif
