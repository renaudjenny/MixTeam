import Assets
import ComposableArchitecture
import SwiftUI

@Reducer
public struct IllustrationPicker {

    @ObservableState
    public struct State: Equatable {
        public let images: IdentifiedArrayOf<MTImage>
        public let color: MTColor
        public var selectedImage: MTImage?

        public init(images: IdentifiedArrayOf<MTImage>, color: MTColor, selectedImage: MTImage?) {
            self.images = images
            self.color = color
            self.selectedImage = selectedImage
        }
    }

    public enum Action: Equatable {
        case imageTapped(MTImage)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .imageTapped(image):
                state.selectedImage = image
                return .none
            }
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
                    Button { viewStore.send(.imageTapped(image)) } label: {
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

#Preview {
    IllustrationPickerView(store: Store(initialState: IllustrationPicker.State(
        images: IdentifiedArrayOf(uniqueElements: MTImage.players),
        color: .strawberry,
        selectedImage: nil
    )) { IllustrationPicker() })
        .backgroundAndForeground(color: .strawberry)
}
