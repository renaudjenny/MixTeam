import ComposableArchitecture
import SwiftUI
import TeamsFeature

@Reducer
public struct ArchiveRow {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var team: Team.State
        @Presents public var deleteConfirmationDialog: ConfirmationDialogState<Action>?
        public var id: Team.State.ID { team.id }

        public init(team: Team.State) {
            self.team = team
        }
    }

    public enum Action: Equatable {
        case unarchive
        case remove
        case confirmRemove(PresentationAction<Action>)
        case cancelRemove(PresentationAction<Action>)
    }

    @Dependency(\.legacyTeamPersistence) var legacyTeamPersistence

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .unarchive:
                state.team.isArchived = false
                return .run { [team = state.team] _ in try await legacyTeamPersistence.updateOrAppend(team.persisted) }
            case .remove:
                state.deleteConfirmationDialog = .removeTeam
                return .none
            case .confirmRemove:
                state.deleteConfirmationDialog = nil
                return .run { [team = state.team] _ in try await legacyTeamPersistence.remove(team.persisted) }
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
            ButtonState.cancel(TextState("Cancel"))
            ButtonState.destructive(TextState("Remove"))
        } message: {
            TextState("Rounds in scoreboard with this team will be automatically removed")
        }
    }
}

public struct ArchiveRowView: View {
    @Bindable var store: StoreOf<ArchiveRow>

    public init(store: StoreOf<ArchiveRow>) {
        self.store = store
    }

    public var body: some View {
        HStack {
            Text(store.team.name)
            Spacer()
            Menu("Edit") {
                Button { store.send(.unarchive) } label: {
                    Label("Unarchive", systemImage: "tray.and.arrow.up")
                }
                Button(role: .destructive) { store.send(.remove) } label: {
                    Label("Delete...", systemImage: "trash")
                }
            }
        }
        .confirmationDialog(store: store.scope(
            state: \.$deleteConfirmationDialog,
            action: \.cancelRemove
        ))
    }
}

#if DEBUG
struct ArchiveRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ArchiveRowView(store: Store(initialState: ArchiveRow.State(team: .previewArchived)) { ArchiveRow() })
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
