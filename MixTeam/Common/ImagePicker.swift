//import SwiftUI
//
//struct ImagePicker: View {
//    @Binding var selection: MTImage
//    let type: ImagePickerType
//    let color: MTColor
//
//    let columns = [GridItem(.adaptive(minimum: 90, maximum: 100))]
//
//    var body: some View {
//        LazyVGrid(columns: columns) {
//            ForEach(images) {
//                Cell(image: $0, selection: $selection.animation(), color: color)
//            }
//        }
//        .padding()
//    }
//
//    private var images: [MTImage] {
//        switch type {
//        case .team: return MTImage.teams
//        case .player: return MTImage.players
//        }
//    }
//}
//
//private struct Cell: View {
//    let image: MTImage
//    @Binding var selection: MTImage
//    let color: MTColor
//    @Environment(\.colorScheme) private var colorScheme
//
//    var body: some View {
//        Button(action: select) {
//            Image(mtImage: image)
//                .resizable()
//                .scaleEffect(selection == image ? 105/100 : 100/100)
//                .frame(width: 48, height: 48)
//                .padding()
//                .background {
//                    if selection == image {
//                        ZStack {
//                            color.backgroundColor(scheme: colorScheme)
//                                .clipShape(RoundedRectangle(cornerRadius: 12))
//                                .shadow(color: Color(white: 20/100, opacity: 20/100), radius: 2, x: 1, y: 1)
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(color.foregroundColor(scheme: colorScheme))
//                                .opacity(20/100)
//                        }
//                    }
//                }
//        }
//        .buttonStyle(.plain)
//    }
//
//    private func select() {
//        selection = image
//    }
//}
//
//extension ImagePicker {
//    enum ImagePickerType {
//        case team, player
//    }
//}
//
//#if DEBUG
//struct PlayerImagePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        Preview()
//    }
//
//    struct Preview: View {
//        @State private var selection: MTImage = .amelie
//
//        var body: some View {
//            VStack {
//                ImagePicker(selection: $selection, type: .player, color: .aluminium)
//                Spacer()
//                Image(mtImage: selection)
//            }
//        }
//    }
//}
//#endif
