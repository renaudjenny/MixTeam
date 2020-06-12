import SwiftUI

struct AddTeamView: View {
    @Environment(\.presentationMode) var presentation
    var createTeam: (String, ImageIdentifier, ColorIdentifier) -> Void
    @State private var name = "Team Name"
    @State private var imageIdentifier: ImageIdentifier = .koala
    @State private var colorIdentifier: ColorIdentifier = .red

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
            Button(action: createTeamAction) {
                Text("Create Team")
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

    private func createTeamAction() {
        createTeam(name, imageIdentifier, colorIdentifier)
        presentation.wrappedValue.dismiss()
    }

    private func colorRow(_ colorIdentifier: ColorIdentifier) -> some View {
        Button(action: { self.colorIdentifier = colorIdentifier }) {
            colorIdentifier.color.frame(width: 50, height: 50)
        }
    }
}

struct AddTeamView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddTeamView(createTeam: { _, _, _ in })
        }
    }
}
