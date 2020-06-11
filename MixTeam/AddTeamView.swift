import SwiftUI

struct AddTeamView: View {
    @Environment(\.presentationMode) var presentation
    var createTeam: (String, ImageIdentifier, Color) -> Void
    @State private var name = "Team Name"
    @State private var imageIdentifier: ImageIdentifier = .koala
    @State private var colorIdentifier: ColorIdentifier = .red

    var body: some View {
        VStack {
            HStack {
                TextField("Name", text: $name)
                teamImage
            }
            List {
                ForEach(UXColor.allColors) {
                    Color($0.color).frame(width: 50, height: 50)
                }
            }
        }
        .onAppear(perform: randomlyChangePlaceholder)
        .navigationBarTitle("Add Team")
    }

    private var teamImage: some View {
        Button(action: { }) {
            imageIdentifier.image
                .resizable()
                .frame(width: 50, height: 50)
        }.foregroundColor(colorIdentifier.color)
    }

    private func randomlyChangePlaceholder() {
        let image = ImageIdentifier.teams.randomElement() ?? imageIdentifier
        let color = ColorIdentifier.allCases.randomElement() ?? colorIdentifier
        imageIdentifier = image
        colorIdentifier = color
        name = "\(color.name) \(image.name)".localizedCapitalized
    }
}

struct AddTeamView_Previews: PreviewProvider {
    static var previews: some View {
        AddTeamView(createTeam: { _, _, _ in })
    }
}
