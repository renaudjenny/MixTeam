import Assets
import ComposableArchitecture
import SwiftUI

public struct IllustrationPicker: ReducerProtocol {

    public struct State: Equatable {
        let images: IdentifiedArrayOf<MTImage>
        let color: MTColor
        var selectedImage: MTImage?

        public init(images: IdentifiedArrayOf<MTImage>, color: MTColor, selectedImage: MTImage?) {
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

public struct IllustrationPickerView: View {
    let store: StoreOf<IllustrationPicker>

    let columns = [GridItem(.adaptive(minimum: 90, maximum: 100))]

    public init(store: StoreOf<IllustrationPicker>) {
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
            .scaleEffect(isSelected ? 105/100 : 100/100)
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
struct IllustrationPicker_Previews: PreviewProvider {
    static var previews: some View {
        IllustrationPickerView(store: Store(initialState: .preview, reducer: IllustrationPicker()))
            .backgroundAndForeground(color: .strawberry)
    }
}

extension IllustrationPicker.State {
    static var preview: Self {
        IllustrationPicker.State(
            images: IdentifiedArrayOf(uniqueElements: MTImage.players),
            color: .strawberry,
            selectedImage: nil
        )
    }
}
#endif
