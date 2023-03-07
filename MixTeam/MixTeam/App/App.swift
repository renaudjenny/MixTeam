import ComposableArchitecture
import PersistenceCore
import ScoresCore
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
        case task
        case tabSelected(Tab)
        case compositionLoader(CompositionLoader.Action)
        case scoreboard(Scoreboard.Action)
        case settings(Settings.Action)
    }

    @Dependency(\.migration) var migration

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
            switch action {
            case .task:
                return .fireAndForget {
                    try await migration.v2toV3()
                    try await migration.v3_0toV3_1()
                }
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .compositionLoader:
                return .none
            case .scoreboard:
                return .none
            case .settings:
                return .none
            }
        }
    }
}
