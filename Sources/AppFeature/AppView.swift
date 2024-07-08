import ComposableArchitecture
import CompositionFeature
import ScoresFeature
import SettingsFeature
import SwiftUI

public struct AppView: View {
    let store: StoreOf<App>
    @Environment(\.colorScheme) private var colorScheme
    private let buttonSize = CGSize(width: 60, height: 60)

    public init(store: StoreOf<App>) {
        self.store = store
    }

    public var body: some View {
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
            #if os(iOS)
            .navigationViewStyle(.stack)
            #endif
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

public extension App.State {
    static var example: Self {
        Self(compositionLoader: .loaded(Composition.State(
            teams: .example,
            standing: .example
        )))
    }
}
#endif
