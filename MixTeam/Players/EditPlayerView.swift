import SwiftUI
import Combine
import UIKit

struct EditPlayerView: View {
    @Environment(\.presentationMode) var presentation
    @State private var name: String
    @State private var imageIdentifier: ImageIdentifier
    @State private var isPlayerImagesPresented = false
    @State private var isAlertPresented = false
    private let id: UUID
    let editPlayer: (Player) -> Void

    init(player: Player, editPlayer: @escaping (Player) -> Void) {
        _name = State(initialValue: player.name)
        _imageIdentifier = State(initialValue: player.imageIdentifier)
        id = player.id
        self.editPlayer = editPlayer
    }

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
        Text(name)
            .font(.largeTitle)
            .padding()
    }

    private var playerImage: some View {
        Button(action: { self.isPlayerImagesPresented = true }, label: {
            imageIdentifier
                .image
                .resizable()
                .scaledToFit()
        })
        .buttonStyle(PlainButtonStyle())
        .accessibility(label: Text("Player Logo"))
    }

    private var playerNameField: some View {
        TextField("", text: $name)
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
        editPlayer(Player(id: id, name: name, imageIdentifier: imageIdentifier))
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
        EditPlayerView(player: Player(name: "Harry", imageIdentifier: .harryPottar)) {
            print($0)
        }
    }
}
