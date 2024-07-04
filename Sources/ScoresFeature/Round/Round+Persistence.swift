import ComposableArchitecture
import Models

extension Round.State {
    var persisted: PersistedRound {
        PersistedRound(id: id, name: name, scores: IdentifiedArrayOf(uniqueElements: scores.map(\.persisted)))
    }
}
