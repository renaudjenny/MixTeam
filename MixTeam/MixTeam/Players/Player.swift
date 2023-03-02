import Assets
import ComposableArchitecture
import Foundation
import ImagePicker

struct Player: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        @BindingState var name = ""
        var image: MTImage = .unknown
        var color: MTColor = .aluminium

        var illustrationPicker: IllustrationPicker.State {
            IllustrationPicker.State(
                images: IdentifiedArrayOf(uniqueElements: MTImage.players),
                color: color,
                selectedImage: image
            )
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case illustrationPicker(IllustrationPicker.Action)
    }

    @Dependency(\.playerPersistence) var playerPersistence

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .fireAndForget { [state] in try await playerPersistence.updateOrAppend(state) }
            case let .illustrationPicker(.didTapImage(image)):
                state.image = image
                return .fireAndForget { [state] in try await playerPersistence.updateOrAppend(state) }
            }
        }
    }
}

extension Player.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case image
    }
}
