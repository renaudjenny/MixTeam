import Assets
import ComposableArchitecture
import SwiftUI

public struct ImagePicker: ReducerProtocol {

    public struct State: Equatable {
        let images: IdentifiedArrayOf<MTImage>
        let color: MTColor
        var selectedImage: MTImage

        init(images: IdentifiedArrayOf<MTImage>, color: MTColor, selectedImage: MTImage) {
            self.images = images
            self.color = color
            self.selectedImage = selectedImage
        }
    }

    public enum Action: Equatable {
        case didTapImage(MTImage)
    }

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .didTapImage(image):
            state.selectedImage = image
            return .none
        }
    }
}

public struct ImagePickerView: View {
    let store: StoreOf<ImagePicker>

    let columns = [GridItem(.adaptive(minimum: 90, maximum: 100))]

    public init(store: StoreOf<ImagePicker>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LazyVGrid(columns: columns) {
                ForEach(viewStore.images, id: \.id) { image in
                    Button { viewStore.send(.didTapImage(image)) } label: {
                        Cell(image: image, color: viewStore.color, isSelected: image == viewStore.selectedImage)
                    }
                }
            }
            .padding()
        }
    }
}

private struct Cell: View {
    let image: MTImage
    let color: MTColor
    let isSelected: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Image(mtImage: image)
            .resizable()
            .scaleEffect(isSelected ? 10/100 : 100/100)
            .frame(width: 48, height: 48)
            .padding()
            .background {
                if isSelected {
                    ZStack {
                        color.backgroundColor(scheme: colorScheme)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color(white: 20/100, opacity: 20/100), radius: 2, x: 1, y: 1)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color.foregroundColor(scheme: colorScheme))
                            .opacity(20/100)
                    }
                }
            }
    }
}

#if DEBUG
struct ImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(store: Store(initialState: .preview, reducer: ImagePicker()))
            .backgroundAndForeground(color: .strawberry)
    }
}

extension ImagePicker.State {
    static var preview: Self {
        ImagePicker.State(
            images: IdentifiedArrayOf(uniqueElements: MTImage.players),
            color: .strawberry,
            selectedImage: .amelie
        )
    }
}
#endif
