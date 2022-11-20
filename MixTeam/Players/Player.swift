import ComposableArchitecture
import Foundation

struct Player: ReducerProtocol {
    struct State: Equatable, Identifiable, Codable {
        let id: UUID
        @BindableState var name = ""
        @BindableState var image: ImageIdentifier = .unknown
        var isStanding = false

        @available(*, deprecated)
        var dprColor: ColorIdentifier

        var color: MTColor
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case setEdit(isPresented: Bool)
        case delete
        case moveBack
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
    }
}
