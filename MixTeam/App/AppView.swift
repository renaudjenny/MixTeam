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
                AppLoadView(store: store.scope(state: \.appLoad, action: App.Action.appLoad))
                    .tag(App.Tab.composition)
                ScoreboardView(store: store.scope(state: \.appLoad.scores, action: App.Action.scores))
                    .tag(App.Tab.scoreboard)
                SettingsView(store: store.scope(state: \.settings, action: App.Action.settings))
                    .tag(App.Tab.settings)
            }
            .navigationViewStyle(.stack)
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

extension Store where State == App.State, Action == App.Action {
    static var preview: Self {
        Self(initialState: .example, reducer: App())
    }
}

extension App.State {
    static var example: Self {
        Self(appLoad: .example)
    }
}
#endif
