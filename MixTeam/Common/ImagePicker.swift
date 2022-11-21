import SwiftUI

struct ImagePicker: View {
    @Binding var selection: MTImage
    let type: ImagePickerType

    let columns = [GridItem(.adaptive(minimum: 120))]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(images) {
                Cell(image: $0, selection: $selection)
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
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: select) {
            Image(mtImage: image)
                .resizable()
                .renderingMode(.template)
                .frame(width: 100, height: 100)
                .padding()
        }
        .buttonStyle(.plain)
        .background {
            if selection == image {
                RoundedRectangle(cornerRadius: 20)
                    .stroke()
            }
        }
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
                ImagePicker(selection: $selection, type: .player)
                Spacer()
                Image(mtImage: selection)
            }
        }
    }
}
#endif
