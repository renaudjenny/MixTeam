import SwiftUI
import Combine
import UIKit

struct EditPlayerView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var playerName: String
    @Binding var imageIdentifier: ImageIdentifier
    @State private var isPlayerImagesPresented = false
    @State private var isAlertPresented = false

    var body: some View {
        ScrollView {
            VStack {
                title
                playerImage.frame(width: 200, height: 200)
                playerNameField
                editPlayerButton
            }
            .sheet(isPresented: $isPlayerImagesPresented) {
                PlayerImagesView(selectedImageIdentifier: self.$imageIdentifier)
            }
            .alert(isPresented: $isAlertPresented) { self.noNameAlert }
        }.modifier(AdaptsToSoftwareKeyboard())
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
        }.buttonStyle(PlainButtonStyle())
    }

    private var playerNameField: some View {
        TextField("", text: $playerName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }

    private var editPlayerButton: some View {
        Button(action: editPlayerAction) {
            Text("Edit Player")
        }
        .padding()
    }

    private func editPlayerAction() {
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

struct EditPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        EditPlayerView(playerName: .constant("Harry"), imageIdentifier: .constant(.harryPottar))
    }
}
