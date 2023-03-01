import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: StoreOf<App>
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAboutPresented = false
    @State private var isScoreboardPresented = false
    private let buttonSize = CGSize(width: 60, height: 60)

    var body: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(send: App.Action.tabSelected)) {
                CompositionLoaderView(
                    store: store.scope(state: \.compositionLoader, action: App.Action.compositionLoader)
                )
                .tag(App.Tab.compositionLoader)
                ScoreboardView(
                    store: store.scope(state: \.scoreboard, action: App.Action.scoreboard)
                )
                .tag(App.Tab.scoreboard)
                SettingsView(
                    store: store.scope(state: \.settings, action: App.Action.settings)
                )
                .tag(App.Tab.settings)
            }
            .task { viewStore.send(.task) }
            .navigationViewStyle(.stack)
        }
    }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(store: .preview)
        .previewDisplayName("Happy path")
        AppView(store: .withError)
        .previewDisplayName("With Error")
    }
}

extension App.State {
    static var example: Self {
        Self(compositionLoader: .loaded(.example))
    }
}
#endif
