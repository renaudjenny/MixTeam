import ComposableArchitecture
import Foundation
import Models
import PersistenceCore
import SwiftUI

@Reducer
public struct Round {
    @ObservableState
    public struct State: Identifiable, Equatable, Hashable {
        public let id: UUID
        public var name: String
        public var scores: IdentifiedArrayOf<Score.State> = []

        public init(id: UUID, name: String, scores: IdentifiedArrayOf<Score.State> = []) {
            self.id = id
            self.name = name
            self.scores = scores
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case scores(IdentifiedActionOf<Score>)
    }

    @Dependency(\.legacyScoresPersistence.updateRound) var legacyUpdateRound

    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .run { [state] _ in try await legacyUpdateRound(state.persisted) }
            case let .scores(.element(id: id, action: .remove)):
                state.scores.remove(id: id)
                return .none
            case .scores:
                return .none
            }
        }
        .forEach(\.scores, action: \.scores) {
            Score()
        }
    }
}

struct RoundView: View {
    @Bindable var store: StoreOf<Round>
    @FocusState var focusedField: Score.State?
    @FocusState var focusedHeader: Round.State?

    var body: some View {
        Section(
            header: TextField("Round name", text: $store.name)
                .focused($focusedHeader, equals: store.state)
        ) {
            ForEachStore(store.scope(state: \.scores, action: \.scores)) { store in
                ScoreRow(store: store, focusedField: _focusedField)
            }
        }
    }
}
