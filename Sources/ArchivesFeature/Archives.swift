import ComposableArchitecture
import LoaderCore
import Models
import PersistenceCore
import SwiftUI
import TeamsFeature

@Reducer
public struct Archives {
    @ObservableState
    public enum State: Equatable {
        case loadingCard
        case loaded(rows: IdentifiedArrayOf<ArchiveRow.State>)
        case errorCard(ErrorCard.State)
    }

    public enum Action: Equatable {
        case update(TaskResult<IdentifiedArrayOf<Team.State>>)
        case loadingCard(LoadingCard.Action)
        case archiveRow(IdentifiedActionOf<ArchiveRow>)
        case errorCard(ErrorCard.Action)
    }

    @Dependency(\.teamPersistence) var teamPersistence

    public init() {}

    public var body: some Reducer<State, Action> {
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
                        await send(.update(TaskResult { try await teams.states }))
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
        .ifCaseLet(\.loaded(rows:), action: \.archiveRow) {
            EmptyReducer()
                .forEach(\.self, action: /.self) {
                    ArchiveRow()
                }
        }
        .ifCaseLet(/State.errorCard, action: /Action.errorCard) {
            ErrorCard()
        }
    }

    private func load(state: inout State) -> Effect<Action> {
        state = .loadingCard
        return .run { _ in await Action.update(TaskResult { try await teamPersistence.load().states }) }
    }
}

public struct ArchivesView: View {
    let store: StoreOf<Archives>

    public init(store: StoreOf<Archives>) {
        self.store = store
    }

    public var body: some View {
        switch store.state {
        case .loadingCard:
            if let store = store.scope(state: \.loadingCard, action: \.loadingCard) {
                LoadingCardView(store: store)
            }
        case .loaded:
            if let store = store.scope(state: \.loaded, action: \.archiveRow) {
                if store.isEmpty {
                    Text("No archived teams")
                } else {
                    List {
                        Section("Teams") {
                            ForEachStore(store, content: ArchiveRowView.init)
                        }
                    }
                }
            }
        case .errorCard:
            if let store = store.scope(state: \.errorCard, action: \.errorCard) {
                ErrorCardView(store: store)
            }
        }
    }
}

#Preview {
    ArchivesView(store: Store(initialState: Archives.State.loaded(rows: [])) { Archives() })
}

#Preview("Archives With Teams and Players") {
    ArchivesView(store: Store(initialState: Archives.State.loaded(
        rows: IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Team.State>.example.map {
            var team = $0
            team.isArchived = true
            return ArchiveRow.State(team: team)
        })
    )) { Archives() })
}

#Preview("Archives With Error") {
    ArchivesView(store: Store(initialState: .loadingCard) {
        Archives()
            .dependency(\.teamPersistence.load, {
                try await Task.sleep(nanoseconds: 1_000_000_000 * 2)
                throw PersistenceError.notFound
            })
        // TODO: Fix the missing important if necessary (with Shared API, it shouldn't be)
        //            .dependency(\.teamPersistence.publisher, {
        //                Fail(error: PersistenceError.notFound).eraseToAnyPublisher().values
        //            })
    })
}
