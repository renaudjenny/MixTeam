import SwiftUI

struct PlayerImagesView: View {
    static let imageIdentifiers: [ImageIdentifier] = ImageIdentifier.players
    @Environment(\.presentationMode) var presentation
    @Binding var selectedImageIdentifier: ImageIdentifier

    var body: some View {
        ScrollView {
            ForEach(Self.imageIdentifiers) { imageIdentifier in
                ImageCell(
                    imageIdentifier: imageIdentifier,
                    isSelected: imageIdentifier == self.selectedImageIdentifier,
                    select: { self.select(imageIdentifier: imageIdentifier) }
                ).accessibility(label: Text(imageIdentifier.name))
            }
        }
    }

    private func select(imageIdentifier: ImageIdentifier) {
        selectedImageIdentifier = imageIdentifier
        presentation.wrappedValue.dismiss()
    }
}

struct PlayerImagesView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerImagesView(
            selectedImageIdentifier: .constant(.amaliePoulain)
        )
    }
}
