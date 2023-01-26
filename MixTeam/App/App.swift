import ComposableArchitecture
import SwiftUI

struct App: ReducerProtocol {
    struct State: Equatable {
        var compositionLoader: CompositionLoader.State = .loadingCard
        var scoreboard: Scoreboard.State = .loadingCard
        var settings = Settings.State()

        var selectedTab: Tab = .compositionLoader
    }

    enum Tab: Equatable {
        case compositionLoader
        case scoreboard
        case settings
    }

    enum Action: Equatable {
        case tabSelected(Tab)
        case compositionLoader(CompositionLoader.Action)
        case scoreboard(Scoreboard.Action)
        case settings(Settings.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.compositionLoader, action: /Action.compositionLoader) {
            CompositionLoader()
        }
        Scope(state: \.scoreboard, action: /Action.scoreboard) {
            Scoreboard()
        }
        Scope(state: \.settings, action: /Action.settings) {
            Settings()
        }
        Reduce { state, action in
            if case let .tabSelected(tab) = action {
                state.selectedTab = tab
                return .none
            }
            return .none
        }
    }
}
