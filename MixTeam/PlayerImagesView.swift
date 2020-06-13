import SwiftUI

// TODO: This appImage approach is a mess. Thing about something different with tuple from scratch for instance
struct PlayerImagesView: View {
    static let imageIdentifiers: [ImageIdentifier] = ImageIdentifier.players
    @Environment(\.presentationMode) var presentation
    @Binding var selectedImageIdentifier: ImageIdentifier

    var body: some View {
        ScrollView {
            ForEach(Self.imageIdentifiers) { imageIdentifier in
                PlayerImageCell(
                    image: imageIdentifier.image,
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

// TODO: refactor rename this Cell because it's use in TeamImagesView as well. And obviously extract it from here!
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
            selectedImageIdentifier: .constant(.amaliePoulain)
        )
    }
}
