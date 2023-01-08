import ComposableArchitecture
import SwiftUI

struct App: ReducerProtocol {
    struct State: Equatable {
        var appLoad = AppData.State()
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
        case appLoad(AppData.Action)
        case scores(Scores.Action)
        case settings(Settings.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.appLoad, action: /Action.appLoad) {
            AppData()
        }
        // TODO: extract Scores from AppLoad.State instead?
        Scope(state: \.appLoad.scores, action: /Action.scores) {
            Scores()
        }
        Scope(state: \.settings, action: /Action.settings) {
            Settings()
        }
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .appLoad:
                return .none
            case .scores:
                return .none
            case .settings:
                return .none
            }
        }
    }
}
