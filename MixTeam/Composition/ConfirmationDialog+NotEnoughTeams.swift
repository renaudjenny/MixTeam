import ComposableArchitecture

extension ConfirmationDialogState where Action == Composition.Action {
    static var notEnoughTeams: Self {
        ConfirmationDialogState(title: TextState("Couldn't Mix Team with less than 2 teams. Go create some teams :)"))
    }
}
