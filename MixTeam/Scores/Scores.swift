import ComposableArchitecture

struct Scores: ReducerProtocol {
    struct State: Equatable {
        private(set) var teams: IdentifiedArrayOf<Team.State> = []
    }

    enum Action: Equatable {
        case addRound
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .addRound:
            return .none
        }
    }
}

extension App.State {
    var scores: Scores.State {
        get {
            Scores.State(teams: teams)
        }
        set {
            // TODO: add scores later
        }
    }
}
