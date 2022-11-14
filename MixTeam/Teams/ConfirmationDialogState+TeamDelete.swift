import ComposableArchitecture
import SwiftUI

extension ConfirmationDialogState where Action == Team.Action {
    static var teamDelete: Self {
        ConfirmationDialogState(
            title: TextState("Are you sure"),
            message: TextState("Removing this team will move back all players to the Standing state"),
            buttons: [.cancel(TextState("Cancel")), .destructive(TextState("Delete"), action: .send(.delete))]
        )
    }
}
