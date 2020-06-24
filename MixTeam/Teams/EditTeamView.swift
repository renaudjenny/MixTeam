import SwiftUI

struct EditTeamView: View {
    @Environment(\.presentationMode) var presentation
    @State private var name: String
    @State private var imageIdentifier: ImageIdentifier
    @State private var colorIdentifier: ColorIdentifier
    @State private var isTeamImagesPresented = false
    private let id: UUID
    private let players: [Player]
    let editTeam: (Team) -> Void

    init(team: Team, editTeam: @escaping (Team) -> Void) {
        _name = State(initialValue: team.name)
        _imageIdentifier = State(initialValue: team.imageIdentifier)
        _colorIdentifier = State(initialValue: team.colorIdentifier)
        id = team.id
        players = team.players
        self.editTeam = editTeam
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                teamImage
            }
            .padding()
            .background(
                colorIdentifier.color
                    .opacity(0.10)
                    .clipShape(RoundedRectangle(cornerRadius: 8)))
                .padding()
            List(ColorIdentifier.allCases, rowContent: colorRow)
            Button(action: editTeamAction) {
                Text("Edit Team")
            }.padding()
        }
        .sheet(isPresented: $isTeamImagesPresented) {
            TeamImagesView(selectedImageIdentifier: self.$imageIdentifier)
        }
        .navigationBarTitle("Add Team")
    }

    private var teamImage: some View {
        Button(action: { self.isTeamImagesPresented = true }, label: {
            imageIdentifier.image
                .resizable()
                .frame(width: 50, height: 50)
        })
        .foregroundColor(colorIdentifier.color)
        .accessibility(label: Text("Team Logo"))
        .accessibility(value: Text(imageIdentifier.name))
    }

    private func editTeamAction() {
        editTeam(Team(
            id: id,
            name: name,
            colorIdentifier: colorIdentifier,
            imageIdentifier: imageIdentifier,
            players: players
        ))
        presentation.wrappedValue.dismiss()
    }

    private func colorRow(_ colorIdentifier: ColorIdentifier) -> some View {
        Button(action: { self.colorIdentifier = colorIdentifier }, label: {
            colorIdentifier.color.frame(width: 50, height: 50)
        })
    }
}

struct EditTeamView_Previews: PreviewProvider {
    static var previews: some View {
        EditTeamView(team: Team(name: "Test", colorIdentifier: .red, imageIdentifier: .koala)) {
            print($0)
        }
    }
}
