import ComposableArchitecture
import Models

extension Scores.State {
    var persisted: PersistedScores {
        PersistedScores(rounds: IdentifiedArrayOf(uniqueElements: rounds.map(\.persisted)))
    }
}
