import ComposableArchitecture
import SwiftUI

struct Archives: ReducerProtocol {
    struct State: Equatable {
        var rows: IdentifiedArrayOf<ArchiveRow.State> = []
        var isLoading = true
        var error: String?
    }

    enum Action: Equatable {
        case task
        case update(TaskResult<IdentifiedArrayOf<Team.State>>)
        case archiveRow(id: Team.State.ID, action: ArchiveRow.Action)
    }

    @Dependency(\.teamPersistence) var teamPersistence

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
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
                    state.rows = IdentifiedArrayOf(
                        uniqueElements: result.filter(\.isArchived).map(ArchiveRow.State.init)
                    )
                    return .none
                case let .failure(error):
                    state.error = error.localizedDescription
                    return .none
                }
            case .archiveRow:
                return .none
            }
        }
        .forEach(\.rows, action: /Action.archiveRow) {
            ArchiveRow()
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
                if viewStore.rows.isEmpty {
                    Text("No archived teams")
                } else {
                    List {
                        Section("Teams") {
                            ForEachStore(
                                store.scope(state: \.rows, action: Archives.Action.archiveRow),
                                content: ArchiveRowView.init
                            )
                        }
                    }
                }
            }
        }
    }

    // TODO: Some duplication here with AppData and ArchivesView
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
            rows: IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Team.State>.example.map {
                var team = $0
                team.isArchived = true
                return ArchiveRow.State(team: team)
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
