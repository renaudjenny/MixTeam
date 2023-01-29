import ComposableArchitecture

@available(*, deprecated, message: "Legacy: use ConfirmationDialogState with Composition.Action instead")
extension AlertState where Action == CompositionLegacy.Action {
    static var notEnoughTeams: Self {
        AlertState(title: TextState("Couldn't Mix Team with less than 2 teams. Go create some teams :)"))
    }
}
