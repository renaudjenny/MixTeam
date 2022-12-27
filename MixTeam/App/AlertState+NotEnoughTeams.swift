import ComposableArchitecture

// TODO: remove
extension AlertState where Action == App.Action {
    static var notEnoughTeams: Self {
        AlertState(title: TextState("Couldn't Mix Team with less than 2 teams. Go create some teams :)"))
    }
}

extension AlertState where Action == Composition.Action {
    static var notEnoughTeams: Self {
        AlertState(title: TextState("Couldn't Mix Team with less than 2 teams. Go create some teams :)"))
    }
}
