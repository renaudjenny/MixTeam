import SwiftUI
import Combine
import UIKit

struct AddPlayerView: View {
    @Environment(\.presentationMode) var presentation
    static let placeholders = ["John", "Mathilde", "Renaud"]
    static let imageIdentifiers: [ImageIdentifier] = PlayerImagesView.imageIdentifiers
    var createPlayer: (String, ImageIdentifier) -> Void
    @State private var playerName: String = "Player name"
    @State private var imageIdentifier: ImageIdentifier = .amaliePoulain
    @State private var keyboardHeight: CGFloat = 0
    @State private var isPlayerImagesPresented = false
    @State private var isAlertPresented = false

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
                PlayerImagesView(selectedImageIdentifier: self.$imageIdentifier)
            }
            .alert(isPresented: $isAlertPresented) { self.noNameAlert }
        }.modifier(AdaptsToSoftwareKeyboard())
    }

    private func randomlyChangePlaceholder() {
        playerName = Self.placeholders.randomElement() ?? playerName
        imageIdentifier = Self.imageIdentifiers.randomElement() ?? imageIdentifier
    }

    private var title: some View {
        Text(playerName)
            .font(.largeTitle)
            .padding()
    }

    private var playerImage: some View {
        Button(action: { self.isPlayerImagesPresented = true }) {
            imageIdentifier
                .image
                .resizable()
                .scaledToFit()
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(label: Text("Player Logo"))
    }

    private var playerNameField: some View {
        TextField("", text: $playerName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }

    private var createPlayerButton: some View {
        Button(action: createPlayerAction) {
            Text("Create Player")
        }
        .padding()
    }

    private func createPlayerAction() {
        createPlayer(playerName, imageIdentifier)
        presentation.wrappedValue.dismiss()
    }

    private var noNameAlert: Alert {
        Alert(
            title: Text("Give a name"),
            message: Text("Please, give a name to the player"),
            dismissButton: .cancel()
        )
    }
}

struct AppPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlayerView(createPlayer: { _, _ in })
    }
}
