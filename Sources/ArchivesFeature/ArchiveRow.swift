import ComposableArchitecture
import SwiftUI
import TeamsCore

public struct ArchiveRow: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public var team: Team.State
        public var deleteConfirmationDialog: ConfirmationDialogState<Action>?
        public var id: Team.State.ID { team.id }

        public init(team: Team.State) {
            self.team = team
        }
    }

    public enum Action: Equatable {
        case unarchive
        case remove
        case confirmRemove
        case cancelRemove
    }

    @Dependency(\.teamPersistence) var teamPersistence

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .unarchive:
                state.team.isArchived = false
                return .fireAndForget { [team = state.team] in try await teamPersistence.updateOrAppend(team.persisted) }
            case .remove:
                state.deleteConfirmationDialog = .removeTeam
                return .none
            case .confirmRemove:
                state.deleteConfirmationDialog = nil
                return .fireAndForget { [team = state.team] in try await teamPersistence.remove(team.persisted) }
            case .cancelRemove:
                state.deleteConfirmationDialog = nil
                return .none
            }
        }
    }
}

extension ConfirmationDialogState where Action == ArchiveRow.Action {
    static var removeTeam: Self {
        ConfirmationDialogState(titleVisibility: .visible) {
            TextState("Are you sure to delete this team?")
        } actions: {
            ButtonState.cancel(TextState("Cancel"), action: .send(.cancelRemove))
            ButtonState.destructive(TextState("Remove"), action: .send(.confirmRemove))
        } message: {
            TextState("Rounds in scoreboard with this team will be automatically removed")
        }
    }
}

public struct ArchiveRowView: View {
    let store: StoreOf<ArchiveRow>

    public init(store: StoreOf<ArchiveRow>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Text(viewStore.team.name)
                Spacer()
                Menu("Edit") {
                    Button { viewStore.send(.unarchive) } label: {
                        Label("Unarchive", systemImage: "tray.and.arrow.up")
                    }
                    Button(role: .destructive) { viewStore.send(.remove) } label: {
                        Label("Delete...", systemImage: "trash")
                    }
                }
            }
            .confirmationDialog(store.scope(state: \.deleteConfirmationDialog), dismiss: .cancelRemove)
        }
    }
}

#if DEBUG
struct ArchiveRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ArchiveRowView(store: Store(initialState: ArchiveRow.State(team: .previewArchived), reducer: ArchiveRow()))
        }
    }
}

public extension Team.State {
    static var previewArchived: Self {
        var team: Self = .preview
        team.isArchived = true
        return team
    }
}
#endif
