import ComposableArchitecture
import SwiftUI

struct Archives: ReducerProtocol {
    struct State: Equatable {
        var teams: IdentifiedArrayOf<Team.State> = []
        var isLoading = true
        var error: String?
    }

    enum Action: Equatable {
        case task
        case update(TaskResult<IdentifiedArrayOf<Team.State>>)
        case unarchive(id: Team.State.ID)
        case remove(id: Team.State.ID)
    }

    @Dependency(\.teamPersistence) var teamPersistence

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            state.isLoading = true
            state.error = nil
            return .run { send in
                await send(.update(TaskResult { try await teamPersistence.load() }))

                for try await teams in teamPersistence.publisher() {
                    await send(.update(TaskResult { teams }))
                }
            }
        case let .update(result):
            state.isLoading = false
            switch result {
            case let .success(result):
                state.teams = result
                return .none
            case let .failure(error):
                state.error = error.localizedDescription
                return .none
            }
        case let .unarchive(id):
            state.teams[id: id]?.isArchived = false
            return .fireAndForget { [team = state.teams[id: id]] in
                guard let team else { return }
                try await teamPersistence.updateOrAppend(team)
            }
        case let .remove(id):
            let team = state.teams[id: id]
            state.teams.remove(id: id)
            return .fireAndForget { [team] in
                guard let team else { return }
                try await teamPersistence.remove(team)
            }
        }
    }
}

struct ArchivesView: View {
    let store: StoreOf<Archives>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.isLoading {
                ProgressView("Loading content from saved data")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task { viewStore.send(.task) }
            } else if let error = viewStore.error {
                errorCardView(description: error)
            } else {
                List {
                    Section("Teams") {
                        ForEach(viewStore.teams.filter(\.isArchived)) { team in
                            HStack {
                                Text(team.name)
                                Spacer()
                                Menu("Edit") {
                                    Button { viewStore.send(.unarchive(id: team.id)) } label: {
                                        Label("Unarchive", systemImage: "tray.and.arrow.up")
                                    }
                                    Button(role: .destructive) { viewStore.send(.remove(id: team.id)) } label: {
                                        Label("Delete...", systemImage: "trash")
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }
    }

    private func errorCardView(description: String) -> some View {
        WithViewStore(store.stateless) { viewStore in
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

#if DEBUG
struct ArchivesView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivesView(store: .preview)

        ArchivesView(store: Store(
            initialState: .previewWithTeamsAndPlayers,
            reducer: Archives()
        ))
        .previewDisplayName("Archives With Teams and Players")

        ArchivesView(store: Store(
            initialState: .preview,
            reducer: Archives()
                .dependency(\.appPersistence.player.publisher, { .with(error: PersistenceError.notFound) })
        ))
        .previewDisplayName("Archives With Error")
    }
}

extension Archives.State {
    static var preview: Self { Archives.State() }
    static var previewWithTeamsAndPlayers: Self {
        Archives.State(
            teams: IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Team.State>.example.map {
                var team = $0
                team.isArchived = true
                return team
            }),
            isLoading: false
        )
    }
}

extension StoreOf<Archives> {
    static var preview: StoreOf<Archives> {
        StoreOf<Archives>(
            initialState: .preview,
            reducer: Archives()
                .dependency(\.appPersistence.team.load, {
                    IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Team.State>.example.map {
                        var team = $0
                        team.isArchived = true
                        return team
                    })
                })
                .dependency(\.appPersistence.player.publisher, {
                    .with(value: IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Player.State>.example.map {
                        var player = $0
                        player.isArchived = true
                        return player
                    }))
                })
        )
    }
}
#endif
