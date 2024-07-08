import ComposableArchitecture

public extension ConfirmationDialogState where Action == Composition.Action {
    static var notEnoughTeams: Self {
        ConfirmationDialogState(titleVisibility: .visible) {
            TextState("Couldn't Mix Team")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
            ButtonState(action: .send(.addTeam, animation: .default)) {
                TextState("Add a new Team")
            }
        } message: {
            TextState("It needs at least 2 teams. Go create some teams :)")
        }
    }
}
