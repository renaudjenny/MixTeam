import ComposableArchitecture
import Foundation

struct Player: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        @BindableState var name = ""
        @BindableState var image: MTImage = .unknown
        var color: MTColor = .aluminium
        var isStanding = false
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

extension Player.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case image
        case color
        case isStanding
    }
}
