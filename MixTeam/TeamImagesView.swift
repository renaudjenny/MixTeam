import SwiftUI

struct TeamImagesView: View {
    static let imageIdentifiers: [ImageIdentifier] = ImageIdentifier.teams
    @Environment(\.presentationMode) var presentation
    @Binding var selectedImageIdentifier: ImageIdentifier

    var body: some View {
        ScrollView {
            ForEach(Self.imageIdentifiers) { imageIdentifier in
                ImageCell(
                    imageIdentifier: imageIdentifier,
                    isSelected: imageIdentifier == self.selectedImageIdentifier,
                    select: { self.select(imageIdentifier: imageIdentifier) }
                )
            }
        }
    }

    private func select(imageIdentifier: ImageIdentifier) {
        selectedImageIdentifier = imageIdentifier
        presentation.wrappedValue.dismiss()
    }
}

struct TeamImagesView_Previews: PreviewProvider {
    static var previews: some View {
        TeamImagesView(selectedImageIdentifier: .constant(.koala))
    }
}
