import ComposableArchitecture
import SwiftUI

struct ScoreboardView: View {
    let store: StoreOf<Scoreboard>

    struct ViewState: Equatable {
        let isLoading: Bool
        let error: String?

        init(state: Scoreboard.State) {
            isLoading = state.isLoading
            error = state.error
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            Group {
                if viewStore.isLoading {
                    ProgressView("Loading content from saved data")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task { viewStore.send(.task) }
                } else if let error = viewStore.error {
                    errorCardView(description: error)
                } else {
                    ScoresView(store: store.scope(state: \.scores, action: Scoreboard.Action.scores))
                }
            }
            .tabItem {
                Label("Scoreboard", systemImage: "list.bullet.clipboard")
            }
        }
    }

    // TODO: Some duplication here with AppData and ArchivesView
    // We should have an ErrorCardView with its own helper store à la ConfirmationDialogState
    private func errorCardView(description: String) -> some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(description)
                Button { viewStore.send(.task, animation: .default) } label: {
                    Text("Retry")
                }
                .buttonStyle(.dashed(color: MTColor.strawberry))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundAndForeground(color: .strawberry)
        }
    }
}

// TODO: add some previews
