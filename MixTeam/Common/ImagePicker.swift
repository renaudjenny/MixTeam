import SwiftUI

struct ImagePicker: View {
    @Binding var selection: ImageIdentifier
    let type: ImagePickerType

    let columns = [GridItem(.adaptive(minimum: 120))]

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns) {
                ForEach(images) {
                    Cell(imageIdentifier: $0, selection: $selection)
                }
            }.padding()
        }
    }

    private var images: [ImageIdentifier] {
        switch type {
        case .team: return ImageIdentifier.teams
        case .player: return ImageIdentifier.players
        }
    }
}

private struct Cell: View {
    let imageIdentifier: ImageIdentifier
    @Binding var selection: ImageIdentifier
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: select) {
            imageIdentifier.image
                .resizable()
                .renderingMode(.template)
                .frame(width: 100, height: 100)
                .padding()
        }
        .buttonStyle(.plain)
        .background {
            if selection == imageIdentifier {
                RoundedRectangle(cornerRadius: 20)
                    .stroke()
            }
        }
    }

    private func select() {
        selection = imageIdentifier
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
        @State private var selection: ImageIdentifier = .girl

        var body: some View {
            VStack {
                ImagePicker(selection: $selection, type: .player)
                Spacer()
                selection.image
            }
        }
    }
}
#endif
