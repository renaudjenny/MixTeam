import ComposableArchitecture
import SwiftUI

struct CompositionLoader: ReducerProtocol {
    enum State: Equatable {
        case loadingCard
        case loaded(Composition.State)
        case errorCard(ErrorCard.State)
    }

    enum Action: Equatable {
        case update(TaskResult<Composition.State>)
        case loadingCard(LoadingCard.Action)
        case composition(Composition.Action)
        case errorCard(ErrorCard.Action)
    }

    @Dependency(\.teamPersistence) var teamPersistence
    @Dependency(\.playerPersistence) var playerPersistence

    var body: some ReducerProtocol<State, Action> {
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
        .ifCaseLet(/State.loadingCard, action: /Action.loadingCard) {
            LoadingCard()
        }
        .ifCaseLet(/State.loaded, action: /Action.composition) {
            Composition()
        }
        .ifCaseLet(/State.errorCard, action: /Action.errorCard) {
            ErrorCard()
        }
    }

    private func load(state: inout State) -> EffectTask<Action> {
        state = .loadingCard
        return .task { await .update(loadTaskResult) }
    }

    private var loadTaskResult: TaskResult<Composition.State> {
        get async {
            await TaskResult {
                let teams = try await teamPersistence.load().filter { !$0.isArchived }
                let playersInTeams = teams.flatMap(\.players)
                let standingPlayers = try await playerPersistence.load().filter {
                    !playersInTeams.map(\.id).contains($0.id)
                }

                return Composition.State(
                    teams: teams,
                    standing: Standing.State(players: standingPlayers)
                )
            }
        }
    }
}

struct CompositionLoaderView: View {
    let store: StoreOf<CompositionLoader>

    var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /CompositionLoader.State.loadingCard,
                action: CompositionLoader.Action.loadingCard,
                then: LoadingCardView.init
            )
            CaseLet(
                state: /CompositionLoader.State.loaded,
                action: CompositionLoader.Action.composition,
                then: CompositionView.init
            )
            CaseLet(
                state: /CompositionLoader.State.errorCard,
                action: CompositionLoader.Action.errorCard,
                then: ErrorCardView.init
            )
        }
        .listStyle(.plain)
        .tabItem {
            Label("Composition", systemImage: "person.2.crop.square.stack")
        }
        .navigationViewStyle(.stack)
    }
}
