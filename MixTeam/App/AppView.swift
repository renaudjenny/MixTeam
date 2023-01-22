import ComposableArchitecture
import SwiftUI
import RenaudJennyAboutView

struct AppView: View {
    let store: StoreOf<App>
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAboutPresented = false
    @State private var isScoreboardPresented = false
    private let buttonSize = CGSize(width: 60, height: 60)

    var body: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(send: App.Action.tabSelected)) {
                AppDataView(store: store.scope(state: \.data, action: App.Action.data))
                    .tag(App.Tab.composition)
                ScoreboardView(store: store.scope(state: \.scoreboard, action: App.Action.scoreboard))
                    .tag(App.Tab.scoreboard)
                SettingsView(store: store.scope(state: \.settings, action: App.Action.settings))
                    .tag(App.Tab.settings)
            }
        }
    }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(store: .preview)
        AppView(store: Store(
            initialState: App.State(),
            reducer: App()
                .dependency(\.appPersistence.load, {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    throw PersistenceError.notFound
                })
        ))
        .previewDisplayName("App View With Error")
    }
}

extension App.State {
    static var example: Self {
        Self(data: .example)
    }
}
#endif
