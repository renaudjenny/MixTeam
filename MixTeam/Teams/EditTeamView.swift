import SwiftUI

struct EditTeamView: View {
    @Environment(\.presentationMode) var presentation
    @State private var name: String
    @State private var imageIdentifier: ImageIdentifier
    @State private var colorIdentifier: ColorIdentifier
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
            teamNameField
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ColorIdentifier.allCases) { colorIdentifier in
                        Button(action: { self.colorIdentifier = colorIdentifier }, label: {
                            colorIdentifier.color
                                .frame(width: 50, height: 50)

                        }).accessibility(label: Text("\(colorIdentifier.name) color"))
                    }
                }
            }
            .padding()
            .background(colorIdentifier.color.brightness(-0.2))
            .modifier(AddDashedCardStyle())
            .padding()
            PlayerImagePicker(team: Team(colorIdentifier: colorIdentifier), selection: $imageIdentifier, type: .team)

        }
        .background(colorIdentifier.color.edgesIgnoringSafeArea(.all))
        .animation(.default)
    }

    private var teamNameField: some View {
        HStack {
            TextField("Edit", text: $name)
                .foregroundColor(Color.white)
                .font(.largeTitle)
                .padding()
                .background(colorIdentifier.color)
                .modifier(AddDashedCardStyle())
                .padding([.top, .leading])
            doneButton
        }
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

    private var doneButton: some View {
        Button(action: editTeamAction, label: {
            Text("Done").foregroundColor(Color.white)
        })
            .padding()
            .background(colorIdentifier.color)
            .modifier(AddDashedCardStyle())
            .padding()

    }
}

struct EditTeamView_Previews: PreviewProvider {
    static var previews: some View {
        EditTeamView(team: Team(name: "Test", colorIdentifier: .red, imageIdentifier: .koala)) {
            print($0)
        }
    }
}
