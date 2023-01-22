import ComposableArchitecture
import SwiftUI

struct App: ReducerProtocol {
    struct State: Equatable {
        var data = AppData.State()
        var scoreboard = Scoreboard.State()
        var settings = Settings.State()

        var selectedTab: Tab = .composition
    }

    enum Tab: Equatable {
        case composition
        case scoreboard
        case settings
    }

    enum Action: Equatable {
        case tabSelected(Tab)
        case data(AppData.Action)
        case scoreboard(Scoreboard.Action)
        case settings(Settings.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.data, action: /Action.data) {
            AppData()
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
