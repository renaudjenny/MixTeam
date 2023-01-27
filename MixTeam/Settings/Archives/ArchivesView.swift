import ComposableArchitecture
import SwiftUI

struct Archives: ReducerProtocol {
    enum State: Equatable {
        case loadingCard
        case loaded(rows: IdentifiedArrayOf<ArchiveRow.State>)
        case errorCard(ErrorCard.State)
    }

    enum Action: Equatable {
        case update(TaskResult<IdentifiedArrayOf<Team.State>>)
        case loadingCard(LoadingCard.Action)
        case archiveRow(id: Team.State.ID, action: ArchiveRow.Action)
        case errorCard(ErrorCard.Action)
    }

    @Dependency(\.teamPersistence) var teamPersistence

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .update(result):
                switch result {
                case let .success(result):
                    state = .loaded(rows: IdentifiedArrayOf(
                        uniqueElements: result.filter(\.isArchived).map(ArchiveRow.State.init)
                    ))
                    return .none
                case let .failure(error):
                    state = .errorCard(ErrorCard.State(description: error.localizedDescription))
                    return .none
                }
            case .loadingCard:
                return load(state: &state).concatenate(with: .run { send in
                    for try await teams in teamPersistence.publisher() {
                        await send(.update(TaskResult { teams }))
                    }
                } catch: { error, send in
                    await send(.update(TaskResult { throw error }))
                })
            case .archiveRow:
                return .none
            case .errorCard(.reload):
                return load(state: &state)
            }
        }
        .ifCaseLet(/State.loadingCard, action: /Action.loadingCard) {
            LoadingCard()
        }
        .ifCaseLet(/State.loaded(rows:), action: /Action.archiveRow(id:action:)) {
            EmptyReducer()
                .forEach(\.self, action: /.self) {
                    ArchiveRow()
                }
        }
        .ifCaseLet(/State.errorCard, action: /Action.errorCard) {
            ErrorCard()
        }
    }

    private func load(state: inout State) -> EffectTask<Action> {
        state = .loadingCard
        return .task { await .update(TaskResult { try await teamPersistence.load() }) }
    }
}

struct ArchivesView: View {
    let store: StoreOf<Archives>

    var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /Archives.State.loadingCard,
                action: Archives.Action.loadingCard,
                then: LoadingCardView.init
            )
            CaseLet(state: /Archives.State.loaded(rows:), action: Archives.Action.archiveRow(id:action:)) { store in
                WithViewStore(store, observe: { $0 }) { viewStore in
                    if viewStore.isEmpty {
                        Text("No archived teams")
                    } else {
                        List {
                            Section("Teams") {
                                ForEachStore(store, content: ArchiveRowView.init)
                            }
                        }
                    }
                }
            }
            CaseLet(
                state: /Archives.State.errorCard,
                action: Archives.Action.errorCard,
                then: ErrorCardView.init
            )
        }
    }
}

#if DEBUG
import Combine

struct ArchivesView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivesView(store: .preview)

        ArchivesView(store: Store(
            initialState: .previewWithTeamsAndPlayers,
            reducer: Archives()
        ))
        .previewDisplayName("Archives With Teams and Players")

        ArchivesView(store: Store(
            initialState: .loadingCard,
            reducer: Archives()
                .dependency(\.teamPersistence.load, {
                    try await Task.sleep(nanoseconds: 1_000_000_000 * 2)
                    throw PersistenceError.notFound
                })
                .dependency(\.teamPersistence.publisher, {
                    Fail(error: PersistenceError.notFound).eraseToAnyPublisher().values
                })
        ))
        .previewDisplayName("Archives With Error")
    }
}

extension Archives.State {
    static var preview: Self { .loaded(rows: []) }
    static var previewWithTeamsAndPlayers: Self {
        .loaded(rows: IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Team.State>.example.map {
            var team = $0
            team.isArchived = true
            return ArchiveRow.State(team: team)
        }))
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
                    .with(value: IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Player.State>.example))
                })
        )
    }
}
#endif
