import SwiftUI


// TODO: remove this file
struct ImageCell: View {
    let imageIdentifier: ImageIdentifier
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            if isSelected {
                imageIdentifier.image
                    .resizable()
                    .scaledToFit()
                    .padding(20)
                    .background(Circle().strokeBorder())
                    .padding()
            } else {
                imageIdentifier.image
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(label: Text(imageIdentifier.name))
    }
}
