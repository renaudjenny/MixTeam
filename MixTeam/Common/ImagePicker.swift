import SwiftUI

struct ImagePicker: View {
    @Binding var selection: MTImage
    let type: ImagePickerType
    let color: MTColor

    let columns = [GridItem(.adaptive(minimum: 90, maximum: 100))]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(images) {
                Cell(image: $0, selection: $selection.animation(), color: color)
            }
        }
        .padding()
    }

    private var images: [MTImage] {
        switch type {
        case .team: return MTImage.teams
        case .player: return MTImage.players
        }
    }
}

private struct Cell: View {
    let image: MTImage
    @Binding var selection: MTImage
    let color: MTColor
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: select) {
            Image(mtImage: image)
                .resizable()
                .frame(width: 48, height: 48)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            selection == image
                            ? color.foregroundColor(scheme: colorScheme).opacity(20/100)
                            : Color.clear
                        )
                }
            
        }
        .buttonStyle(.plain)
    }

    private func select() {
        selection = image
    }
}

extension ImagePicker {
    enum ImagePickerType {
        case team, player
    }
}

#if DEBUG
struct PlayerImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    struct Preview: View {
        @State private var selection: MTImage = .girl

        var body: some View {
            VStack {
                ImagePicker(selection: $selection, type: .player, color: .aluminium)
                Spacer()
                Image(mtImage: selection)
            }
        }
    }
}
#endif
