import SwiftUI

struct PlayerImagesView: View {
    static let images: [Image] = [#imageLiteral(resourceName: "harry-pottar"), #imageLiteral(resourceName: "dark-vadir"), #imageLiteral(resourceName: "amalie-poulain"), #imageLiteral(resourceName: "lara-craft"), #imageLiteral(resourceName: "the-botman"), #imageLiteral(resourceName: "wander-woman")].map(Image.init(uiImage:))
    @Environment(\.presentationMode) var presentation
    @Binding var selectedImage: Image

    var body: some View {
        ScrollView {
            ForEach(images, id: \.index) { image, _ in
                PlayerImageCell(
                    image: image,
                    isSelected:  image == self.selectedImage,
                    select: { self.selectImage(image) }
                )
            }
        }
    }

    private var images: [(image: Image, index: Int)] {
        Self.images.enumerated().map { ($1, $0) }
    }

    private func selectImage(_ image: Image) {
        selectedImage = image
        presentation.wrappedValue.dismiss()
    }
}

struct PlayerImageCell: View {
    let image: Image
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            if isSelected {
                image
                    .resizable()
                    .scaledToFit()
                    .padding(20)
                    .background(Circle().strokeBorder())
                    .padding()
            } else {
                image
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            }
        }.buttonStyle(PlainButtonStyle())
    }
}

struct PlayerImagesView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerImagesView(
            selectedImage: .constant(PlayerImagesView.images.first ?? Image("unknown"))
        )
    }
}
