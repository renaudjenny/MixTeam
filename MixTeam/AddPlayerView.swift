import SwiftUI
import Combine
import UIKit

struct AddPlayerView: View {
    static let placeholders = ["John", "Mathilde", "Renaud"]
    static let images: [Image] = PlayerImagesView.images
    @State private var playerName: String = "Player name"
    @State private var image: Image = .init(uiImage: #imageLiteral(resourceName: "unknown"))
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        VStack {
            title
            resizedImage
            playerNameField
            createPlayerButton
        }
        .animation(.default)
        .onAppear(perform: randomlyChangePlaceholder)
    }

    private func randomlyChangePlaceholder() {
        playerName = Self.placeholders.randomElement() ?? playerName
        image = Self.images.randomElement() ?? image
    }

    private var title: some View {
        Text(playerName)
            .font(.largeTitle)
            .padding()
    }

    private var resizedImage: some View {
        image
            .resizable()
            .frame(maxWidth: 200, maxHeight: 200)
            .scaledToFit()
    }

    private var playerNameField: some View {
        TextField("", text: $playerName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }

    private var createPlayerButton: some View {
        Button(action: createPlayer) {
            Text("Create Player")
        }
        .padding()
        .padding(.bottom, keyboardHeight)
        .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    }

    private func createPlayer() {

    }
}

struct AppPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlayerView()
    }
}

class AddPlayerHostingController: UIHostingController<AddPlayerView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: AddPlayerView())
    }
}
