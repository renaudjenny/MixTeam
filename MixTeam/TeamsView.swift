import SwiftUI

struct TeamsView: View {
    @ObservedObject var viewModel = TeamsViewModel()

    var body: some View {
        NavigationView {
            teamsView
        }
    }

    private var teamsView: some View {
        List {
            ForEach(viewModel.teams, content: teamRow)
                .onDelete(perform: viewModel.deleteTeam)
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Players")
        .navigationBarItems(trailing: addTeamButton)
    }

    private func teamRow(team: Team) -> some View {
        Button(action: { }) {
            HStack {
                team.image?.imageIdentifier.image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.leading, 20)
                    .padding(.trailing)
                Text(team.name)
                Spacer()
            }.foregroundColor(Color(team.color.color))
        }
        .buttonStyle(DefaultButtonStyle())
        .padding([.top, .bottom], 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowInsets(EdgeInsets())
        .background(Color(team.color.color).opacity(0.10))
    }

    private var addTeamButton: some View {
        NavigationLink(destination: AddTeamView(createTeam: viewModel.createTeam), label: { Image(systemName: "plus") })
    }
}

class TeamsHostingController: UIHostingController<TeamsView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: TeamsView())
    }
}
