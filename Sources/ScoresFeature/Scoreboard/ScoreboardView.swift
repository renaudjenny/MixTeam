import ComposableArchitecture
import LoaderCore
import Models
import PersistenceCore
import SwiftUI

public struct ScoreboardView: View {
    let store: StoreOf<Scoreboard>

    public init(store: StoreOf<Scoreboard>) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /Scoreboard.State.loadingCard,
                action: Scoreboard.Action.loadingCard,
                then: LoadingCardView.init
            )
            CaseLet(
                state: /Scoreboard.State.loaded,
                action: Scoreboard.Action.scores,
                then: ScoresView.init
            )
            CaseLet(
                state: /Scoreboard.State.errorCard,
                action: Scoreboard.Action.errorCard,
                then: ErrorCardView.init
            )
        }
        .tabItem {
            Label("Scoreboard", systemImage: "list.bullet.clipboard")
        }
    }
}

#if DEBUG
struct ScorebordView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView(store: .preview)
        ScoreboardView(store: .previewWithLongLoading)
            .previewDisplayName("Scoreboard View With Long Loading")
        ScoreboardView(store: .previewWithError)
            .previewDisplayName("Scoreboard View With Error")
    }
}

extension Store where State == Scoreboard.State, Action == Scoreboard.Action {
    static var preview: Self {
        Self(initialState: .loadingCard, reducer: Scoreboard())
    }
    static var previewWithLongLoading: Self {
        Self(
            initialState: .loadingCard,
            reducer: Scoreboard()
                .dependency(\.scoresPersistence.load, {
                    try await Task.sleep(nanoseconds: 1_000_000_000 * 5)
                    return .previewWithScores(count: 5)
                })
        )
    }
    static var previewWithError: Self {
        Self(
            initialState: .loadingCard,
            reducer: Scoreboard()
                .dependency(\.scoresPersistence.load, {
                    try await Task.sleep(nanoseconds: 1_000_000_000 * 2)
                    throw FakeError()
                })
        )
    }

    struct FakeError: Error {}
}

extension PersistedScores {
    static func previewWithScores(count: Int) -> Self {
        ScoresFeature.Scores.State.previewWithScores(count: count).persisted
    }
}
#endif
