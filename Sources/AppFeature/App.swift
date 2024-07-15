import ComposableArchitecture
import CompositionFeature
import PersistenceCore
import ScoresFeature
import SettingsFeature
import SwiftUI

public typealias Settings = SettingsFeature.Settings

@Reducer
public struct App {
    @ObservableState
    public struct State: Equatable {
        public var compositionLoader: CompositionLoader.State = .loadingCard
        public var scoreboard: Scoreboard.State = .loadingCard
        public var settings = Settings.State()

        public var selectedTab: Tab = .compositionLoader
    }

    public enum Tab: Equatable {
        case compositionLoader
        case scoreboard
        case settings
    }

    public enum Action: Equatable {
        case task
        case tabSelected(Tab)
        case compositionLoader(CompositionLoader.Action)
        case scoreboard(Scoreboard.Action)
        case settings(Settings.Action)
    }

    public init() {}

    @Dependency(\.migration) var migration

    public var body: some Reducer<State, Action> {
        Scope(state: \.compositionLoader, action: \.compositionLoader) {
            CompositionLoader()
        }
        Scope(state: \.scoreboard, action: \.scoreboard) {
            Scoreboard()
        }
        Scope(state: \.settings, action: \.settings) {
            Settings()
        }
        Reduce { state, action in
            switch action {
            case .task:
                return .run { _ in
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
