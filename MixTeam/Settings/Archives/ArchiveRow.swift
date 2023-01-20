import ComposableArchitecture
import SwiftUI

struct ArchiveRow: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var team: Team.State
        var deleteConfirmationDialog: ConfirmationDialogState<Action>?
        var id: Team.State.ID { team.id }

        init(team: Team.State) {
            self.team = team
        }
    }

    enum Action: Equatable {
        case unarchive
        case remove
        case confirmRemove
        case cancelRemove
    }

    @Dependency(\.teamPersistence) var teamPersistence

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .unarchive:
                state.team.isArchived = false
                return .fireAndForget { [team = state.team] in try await teamPersistence.updateOrAppend(team) }
            case .remove:
                state.deleteConfirmationDialog = .removeTeam
                return .none
            case .confirmRemove:
                state.deleteConfirmationDialog = nil
                return .fireAndForget { [team = state.team] in try await teamPersistence.remove(team) }
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

struct ArchiveRowView: View {
    let store: StoreOf<ArchiveRow>

    var body: some View {
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
