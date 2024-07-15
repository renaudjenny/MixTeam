import ComposableArchitecture
import LoaderCore
import SwiftUI

@Reducer
public struct CompositionLoader {
    @ObservableState
    public enum State: Equatable {
        case loadingCard
        case loaded(Composition.State)
        case errorCard(ErrorCard.State)
    }

    public enum Action: Equatable {
        case update(TaskResult<Composition.State>)
        case loadingCard(LoadingCard.Action)
        case composition(Composition.Action)
        case errorCard(ErrorCard.Action)
    }

    @Dependency(\.teamPersistence) var teamPersistence
    @Dependency(\.playerPersistence) var playerPersistence

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .update(result):
                switch result {
                case let .success(result):
                    state = .loaded(result)
                    return .none
                case let .failure(error):
                    state = .errorCard(ErrorCard.State(description: error.localizedDescription))
                    return .none
                }
            case .loadingCard:
                return load(state: &state).concatenate(with: .merge(
                    .run { send in
                        for try await _ in teamPersistence.publisher() {
                            await send(.update(await loadTaskResult))
                        }
                    } catch: { error, send in
                        await send(.update(.failure(error)))
                    },
                    .run { send in
                        for try await _ in playerPersistence.publisher() {
                            await send(.update(await loadTaskResult))
                        }
                    } catch: { error, send in
                        await send(.update(.failure(error)))
                    }
                ))
            case .composition:
                return .none
            case .errorCard(.reload):
                return load(state: &state)
            }
        }
        .ifCaseLet(\.loadingCard, action: \.loadingCard) {
            LoadingCard()
        }
        .ifCaseLet(\.loaded, action: \.composition) {
            Composition()
        }
        .ifCaseLet(\.errorCard, action: \.errorCard) {
            ErrorCard()
        }
    }

    private func load(state: inout State) -> Effect<Action> {
        state = .loadingCard
        return .run { send in await send(.update(loadTaskResult)) }
    }

    private var loadTaskResult: TaskResult<Composition.State> {
        get async {
            await TaskResult {
                let teams = try await teamPersistence.load().filter { !$0.isArchived }.states
                let playersInTeams = teams.flatMap(\.players)
                let standingPlayers = try await playerPersistence.load()
                    .filter { !playersInTeams.map(\.id).contains($0.id) }
                    .map(\.state)

                return Composition.State(
                    teams: teams,
                    standing: Standing.State(players: IdentifiedArrayOf(uniqueElements: standingPlayers))
                )
            }
        }
    }
}

public struct CompositionLoaderView: View {
    let store: StoreOf<CompositionLoader>

    public init(store: StoreOf<CompositionLoader>) {
        self.store = store
    }

    public var body: some View {
        NavigationView {
            Group {
                switch store.state {
                case .loadingCard:
                    if let store = store.scope(state: \.loadingCard, action: \.loadingCard) {
                        LoadingCardView(store: store)
                    }
                case .loaded:
                    if let store = store.scope(state: \.loaded, action: \.composition) {
                        CompositionView(store: store)
                    }
                case .errorCard:
                    if let store = store.scope(state: \.errorCard, action: \.errorCard) {
                        ErrorCardView(store: store)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Composition")
        }
        .tabItem {
            Label("Composition", systemImage: "person.2.crop.square.stack")
        }
   }
}
