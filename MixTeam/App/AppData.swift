import ComposableArchitecture
import SwiftUI

struct AppData: ReducerProtocol {
    struct State: Equatable {
        var teams: IdentifiedArrayOf<Team.State> = []
        var composition = CompositionLegacy.State()
        var isLoading = true
        var error: String?
    }

    enum Action: Equatable {
        case task
        case update(TaskResult<State>)
        case updateTeams(TaskResult<IdentifiedArrayOf<Team.State>>)
        case composition(CompositionLegacy.Action)
    }

    @Dependency(\.appPersistence) var appPersistence
    @Dependency(\.teamPersistence) var teamPersistence
    @Dependency(\.shufflePlayers) var shufflePlayers
    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.composition, action: /Action.composition) {
            CompositionLegacy()
        }
        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    await send(.update(TaskResult { try await appPersistence.load() }))

                    for try await teams in teamPersistence.publisher() {
                        await send(.updateTeams(TaskResult { teams }))
                    }
                }
                .animation(.default)
            case let .update(result):
                state.isLoading = false
                switch result {
                case let .success(result):
                    state.teams = result.teams
                    state.composition = result.composition
                    return .none
                case let .failure(error):
                    state.error = error.localizedDescription
                    return .none
                }
            case let .updateTeams(result):
                switch result {
                case let .success(teams):
                    state.teams = teams
                    state.composition.teams = teams.filter { !$0.isArchived }
                    return .fireAndForget { [state] in try await appPersistence.save(state) }
                case let .failure(error):
                    state.error = error.localizedDescription
                    return .none
                }
            case .composition(.addTeam):
                state.teams.append(contentsOf: state.composition.teams)
                return .fireAndForget { [state] in try await appPersistence.save(state) }
            case let .composition(.team(id, .binding)):
                guard let team = state.composition.teams[id: id] else { return .none }
                state.teams.updateOrAppend(team)
                return .none
            case .composition:
                return .none
            }
        }
    }
}

struct AppDataView: View {
    let store: StoreOf<AppData>

    struct ViewState: Equatable {
        let isLoading: Bool
        let error: String?

        init(state: AppData.State) {
            isLoading = state.isLoading
            error = state.error
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            NavigationView {
                if viewStore.isLoading {
                    ProgressView("Loading content from saved data")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task { viewStore.send(.task) }
                } else if let error = viewStore.error {
                    errorCardView(description: error)
                } else {
                    CompositionLegacyView(store: store.scope(state: \.composition, action: AppData.Action.composition))
                }

            }
            .listStyle(.plain)
            .tabItem {
                Label("Composition", systemImage: "person.2.crop.square.stack")
            }
            .navigationViewStyle(.stack)
        }
    }

    // TODO: Use ErrorCard ReducerProtocol instead
   private func errorCardView(description: String) -> some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(description)
                Button { viewStore.send(.task, animation: .default) } label: {
                    Text("Retry")
                }
                .buttonStyle(.dashed(color: MTColor.strawberry))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundAndForeground(color: .strawberry)
        }
    }
}
