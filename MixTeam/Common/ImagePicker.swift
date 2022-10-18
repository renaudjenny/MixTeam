import SwiftUI

struct ImagePicker: View {
    let color: ColorIdentifier
    @Binding var selection: ImageIdentifier
    let type: ImagePickerType

    let columns = [GridItem(.adaptive(minimum: 120))]

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns) {
                ForEach(images) {
                    Cell(imageIdentifier: $0, color: color, selection: $selection)
                }
            }.padding()
        }
        .background(color.color)
        .modifier(AddDashedCardStyle())
        .padding()
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
    let color: ColorIdentifier
    @Binding var selection: ImageIdentifier

    var body: some View {
        Button(action: select) {
            imageIdentifier.image
                .resizable()
                .renderingMode(.template)
                .frame(width: 100, height: 100)
                .padding()
                .foregroundColor(imageForegroundColor)
        }
        .background(background)
        .foregroundColor(Color.white)
    }

    private func select() {
        selection = imageIdentifier
    }

    private var imageForegroundColor: Color {
        if selection == imageIdentifier {
            return color.color
        } else {
            return .white
        }

    }

    private var background: some View {
        Group {
            if selection == imageIdentifier {
                Splash2().shadow(radius: 5)
            }
        }
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
        var selection: Binding<ImageIdentifier> { .constant(.girl) }

        var body: some View {
            VStack {
                ImagePicker(color: .red, selection: selection, type: .player)
                Spacer()
                TeamRow(store: .preview)
                Text("Selection: \(selection.wrappedValue.rawValue)")
            }
        }
    }
}
#endif
