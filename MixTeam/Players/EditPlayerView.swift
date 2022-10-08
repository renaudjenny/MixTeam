import SwiftUI
import Combine
import UIKit

struct EditPlayerView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var player: DprPlayer
    let team: DprTeam

    var body: some View {
        VStack {
            playerNameField
            ImagePicker(color: team.colorIdentifier, selection: $player.imageIdentifier, type: .player)
        }
        .background(team.colorIdentifier.color.edgesIgnoringSafeArea(.all))
    }

    private var title: some View {
        Text(player.name)
            .font(.largeTitle)
            .padding()
    }

    private var playerNameField: some View {
        HStack {
            TextField("Edit", text: $player.name)
                .foregroundColor(Color.white)
                .font(.title)
                .padding()
                .background(team.colorIdentifier.color)
                .modifier(AddDashedCardStyle())
                .padding(.leading)
            doneButton.padding(.trailing)
        }.padding(.top)
    }

    private var doneButton: some View {
        Button(action: { self.presentation.wrappedValue.dismiss() }, label: {
            Image(systemName: "checkmark")
                .foregroundColor(team.colorIdentifier.color)
                .padding()
                .background(Splash2())
                .foregroundColor(.white)
        }).accessibility(label: Text("Done"))
    }
}

struct EditPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    struct Preview: View {
        @State private var player = DprPlayer(name: "Amelia", imageIdentifier: .girl)
        let team = DprTeam(name: "Green Koala", colorIdentifier: .green, imageIdentifier: .koala)

        var body: some View {
            EditPlayerView(player: $player, team: team)
        }
    }
}
