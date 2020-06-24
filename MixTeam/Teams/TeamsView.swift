import SwiftUI

struct TeamsView: View, TeamsLogic {
    @EnvironmentObject var teamsStore: TeamsStore
    @State private var editedTeam: Team?

    var body: some View {
        NavigationView {
            teamsView
        }
    }

    private var teamsView: some View {
        List {
            ForEach(teamsList, content: teamRow)
                .onDelete(perform: deleteTeam)
        }
        .listStyle(GroupedListStyle())
        .sheet(item: $editedTeam, content: edit)
        .navigationBarTitle("Teams")
        .navigationBarItems(trailing: addTeamButton)
    }

    private func teamRow(team: Team) -> some View {
        Button(action: { self.editedTeam = team }, label: {
            HStack {
                team.imageIdentifier.image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.leading, 20)
                    .padding(.trailing)
                Text(team.name)
                Spacer()
            }.foregroundColor(team.colorIdentifier.color)
        })
        .buttonStyle(DefaultButtonStyle())
        .padding([.top, .bottom], 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowInsets(EdgeInsets())
        .background(team.colorIdentifier.color.opacity(0.10))
    }

    private var addTeamButton: some View {
        NavigationLink(destination: AddTeamView(createTeam: createTeam), label: {
            Image(systemName: "plus").accessibility(label: Text("Add"))
        })
    }

    private func edit(team: Team) -> some View {
        EditTeamView(team: team, editTeam: editTeam)
    }
}

class TeamsHostingController: UIHostingController<TeamsView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: TeamsView())
    }
}
