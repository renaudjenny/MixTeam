import ComposableArchitecture
import SwiftUI

@available (*, deprecated, message: "Legacy: use CompositionLoader instead")
struct AppData: ReducerProtocol {
    struct State: Equatable {
        var teams: IdentifiedArrayOf<Team.State> = []
        var composition = CompositionLegacy.State()
        var isLoading = true
        var error: String?
    }

    enum Action: Equatable {
        case task
        case update(TaskResult<State>)
        case updateTeams(TaskResult<IdentifiedArrayOf<Team.State>>)
        case composition(CompositionLegacy.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}

@available (*, deprecated, message: "Legacy: use CompositionLoaderView instead")
struct AppDataView: View {
    let store: StoreOf<AppData>

    var body: some View {
        Text("Legacy: use CompositionLoader instead")
    }
}
