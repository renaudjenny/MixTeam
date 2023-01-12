import ComposableArchitecture
import SwiftUI

struct App: ReducerProtocol {
    struct State: Equatable {
        var data = AppData.State()
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
        case settings(Settings.Action)
    }

    var body: some ReducerProtocol<State, Action> {

        // TODO: check if this can be replaced by listening to persistence changes
        Reduce { state, action in
            if case let .data(.composition(.deleteTeams(indexSet))) = action {
                for index in indexSet {
                    var team = state.data.composition.teams[index]
                    team.isArchived = true
                    state.settings.archives.teams.updateOrAppend(team)
                }
            }
            return .none
        }

        Scope(state: \.data, action: /Action.data) {
            AppData()
        }
        Scope(state: \.settings, action: /Action.settings) {
            Settings()
        }
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .data:
                return .none

            // TODO: check if this can be replaced by listening to persistence changes
            case let .settings(.archives(.unarchive(id))):
                guard let team = state.data.teams[id: id] else { return .none }
                return .task { .data(.composition(.unarchiveTeam(team))) }
            case .settings:
                return .none
            }
        }
    }
}
