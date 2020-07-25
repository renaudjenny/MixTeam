import SwiftUI

struct EditTeamView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var team: Team

    var body: some View {
        VStack {
            teamNameField
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ColorIdentifier.allCases) { colorIdentifier in
                        Button(action: { self.team.colorIdentifier = colorIdentifier }, label: {
                            colorIdentifier.color
                                .frame(width: 50, height: 50)

                        }).accessibility(label: Text("\(colorIdentifier.name) color"))
                    }
                }
            }
            .padding()
            .background(team.colorIdentifier.color.brightness(-0.2))
            .modifier(AddDashedCardStyle())
            .padding()
            ImagePicker(team: team, selection: $team.imageIdentifier, type: .team)

        }
        .background(color.edgesIgnoringSafeArea(.all))
        .animation(.default)
    }

    private var teamNameField: some View {
        HStack {
            TextField("Edit", text: $team.name)
                .foregroundColor(Color.white)
                .font(.largeTitle)
                .padding()
                .background(color)
                .modifier(AddDashedCardStyle())
                .padding([.top, .leading])
            doneButton.padding(.trailing)
        }
    }

    private var doneButton: some View {
        Button(action: { self.presentation.wrappedValue.dismiss() }, label: {
            Text("Done").foregroundColor(Color.white)
        }).buttonStyle(CommonButtonStyle(color: color))
    }

    var color: Color { team.colorIdentifier.color }
}

struct EditTeamView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    struct Preview: View {
        @State private var team = Team(
            name: "Test",
            colorIdentifier: .red,
            imageIdentifier: .koala
        )

        var body: some View {
            EditTeamView(team: $team)
        }
    }
}

struct EditTeamViewInteractive_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .environmentObject(TeamsStore())
    }

    struct Preview: View, TeamRowPreview {
        @EnvironmentObject var teamsStore: TeamsStore
        @State private var isEdited = false
        private var team: Team { teamsStore.teams[1] }

        var body: some View {
            TeamRow(team: team, callbacks: callbacks)
                .sheet(isPresented: $isEdited) {
                    EditTeamView(team: self.$teamsStore.teams[1])
            }
        }

        private var callbacks: TeamRow.Callbacks {
            .init(
                editTeam: { _ in self.isEdited = true },
                deleteTeam: debuggableCallbacks.deleteTeam,
                editPlayer: debuggableCallbacks.editPlayer,
                moveBackPlayer: debuggableCallbacks.moveBackPlayer
            )
        }
    }
}
