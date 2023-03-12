import ComposableArchitecture
import CompositionFeature
import PersistenceCore
import ScoresFeature
import SettingsFeature
import SwiftUI

public typealias Settings = SettingsFeature.Settings

public struct App: ReducerProtocol {
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

    public var body: some ReducerProtocol<State, Action> {
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

public extension StoreOf<App> {
    static var live: StoreOf<App> {
        Store(initialState: App.State(), reducer: App())
    }
    #if DEBUG
    static var preview: StoreOf<App> {
        Store(
            initialState: .example,
            reducer: App()
                .dependency(\.playerPersistence, .preview)
        )
    }

    static var withError: StoreOf<App> {
        Store(
            initialState: App.State(),
            reducer: App()
                .dependency(\.playerPersistence, .preview)
                .dependency(\.teamPersistence.load, {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    throw PersistenceError.notFound
                })
        )
    }
    #endif
}
