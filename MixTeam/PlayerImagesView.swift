import SwiftUI

struct PlayerImagesView: View {
    static let images: [Image] = [#imageLiteral(resourceName: "harry-pottar"), #imageLiteral(resourceName: "dark-vadir"), #imageLiteral(resourceName: "amalie-poulain"), #imageLiteral(resourceName: "lara-craft"), #imageLiteral(resourceName: "the-botman"), #imageLiteral(resourceName: "wander-woman")].map(Image.init(uiImage:))

    var body: some View {
        VStack {
            ForEach(images, id: \.index) {
                $0.image
            }
        }
    }

    private var images: [(image: Image, index: Int)] {
        Self.images.enumerated().map { ($1, $0) }
    }
}

struct PlayerImagesView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerImagesView()
    }
}
