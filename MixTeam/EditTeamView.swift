import SwiftUI

struct EditTeamView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var team: Team
    @State private var isTeamImagesPresented = false

    var body: some View {
        VStack {
            HStack {
                TextField("Name", text: $team.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                teamImage
            }
            .padding()
            .background(
                team.colorIdentifier.color
                    .opacity(0.10)
                    .clipShape(RoundedRectangle(cornerRadius: 8)))
                .padding()
            List(ColorIdentifier.allCases, rowContent: colorRow)
            Button(action: editTeamAction) {
                Text("Edit Team")
            }.padding()
        }
        .sheet(isPresented: $isTeamImagesPresented) {
            TeamImagesView(selectedImageIdentifier: self.$team.imageIdentifier)
        }
        .navigationBarTitle("Add Team")
    }

    private var teamImage: some View {
        Button(action: { self.isTeamImagesPresented = true }) {
            team.imageIdentifier.image
                .resizable()
                .frame(width: 50, height: 50)
        }.foregroundColor(team.colorIdentifier.color)
    }

    private func editTeamAction() {
        presentation.wrappedValue.dismiss()
    }

    private func colorRow(_ colorIdentifier: ColorIdentifier) -> some View {
        Button(action: { self.team.colorIdentifier = colorIdentifier }) {
            colorIdentifier.color.frame(width: 50, height: 50)
        }
    }
}

struct EditTeamView_Previews: PreviewProvider {
    static var previews: some View {
        EditTeamView(
            team: .constant(Team(name: "Test", colorIdentifier: .red, imageIdentifier: .koala))
        )
    }
}
