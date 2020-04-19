import SwiftUI
import Combine
import UIKit

struct AddPlayerView: View {
    static let placeholders = ["John", "Mathilde", "Renaud"]
    static let images: [Image] = PlayerImagesView.images
    @State private var playerName: String = "Player name"
    @State private var image: Image = .init(uiImage: #imageLiteral(resourceName: "unknown"))
    @State private var keyboardHeight: CGFloat = 0
    @State private var isPlayerImagesPresented = false

    var body: some View {
        ScrollView {
            VStack {
                title
                playerImage.frame(width: 200, height: 200)
                playerNameField
                createPlayerButton
            }
            .onAppear(perform: randomlyChangePlaceholder)
            .sheet(isPresented: $isPlayerImagesPresented) {
                PlayerImagesView(selectedImage: self.$image)
            }
        }.keyboardAdaptive()
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

    private var playerImage: some View {
        Button(action: { self.isPlayerImagesPresented = true }) {
            image
                .resizable()
                .scaledToFit()
        }.buttonStyle(PlainButtonStyle())
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
