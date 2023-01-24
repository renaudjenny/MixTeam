import ComposableArchitecture

// TODO: move to its own file
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
                // TODO: implement something keeping update from team & player persistence update
                return load(state: &state)
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
        return .task { await .update(TaskResult {
            let teams = try await teamPersistence.load().filter { !$0.isArchived }
            let playersInTeams = teams.flatMap(\.players)
            let standingPlayers = try await playerPersistence.load().filter { !playersInTeams.contains($0) }

            return Composition.State(
                teams: teams,
                standing: Standing.State(players: standingPlayers)
            )
        }) }
    }
}

struct Composition: ReducerProtocol {
    struct State: Equatable {
        var teams: IdentifiedArrayOf<Team.State> = []
        var standing: Standing.State
    }

    enum Action: Equatable {

    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
