import SwiftUI

struct TeamsView: View {
    @ObservedObject var viewModel = TeamsViewModel()
    @State private var editedTeam: Team? = nil

    var body: some View {
        NavigationView {
            teamsView
        }
    }

    private var teamsView: some View {
        List {
            ForEach(viewModel.teams.dropFirst(), content: teamRow)
                .onDelete(perform: viewModel.deleteTeam)
        }
        .listStyle(GroupedListStyle())
        .sheet(item: $editedTeam, content: edit)
        .navigationBarTitle("Teams")
        .navigationBarItems(trailing: addTeamButton)
    }

    private func teamRow(team: Team) -> some View {
        Button(action: { self.editedTeam = team }) {
            HStack {
                team.imageIdentifier.image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.leading, 20)
                    .padding(.trailing)
                Text(team.name)
                Spacer()
            }.foregroundColor(team.colorIdentifier.color)
        }
        .buttonStyle(DefaultButtonStyle())
        .padding([.top, .bottom], 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowInsets(EdgeInsets())
        .background(team.colorIdentifier.color.opacity(0.10))
    }

    private var addTeamButton: some View {
        NavigationLink(destination: AddTeamView(createTeam: viewModel.createTeam), label: { Image(systemName: "plus") })
    }

    private func edit(team: Team) -> some View {
        guard let teamBinding = viewModel.teamBinding(for: team) else {
            return EmptyView().eraseToAnyView()
        }
        return EditTeamView(team: teamBinding).eraseToAnyView()
    }
}

class TeamsHostingController: UIHostingController<TeamsView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: TeamsView())
    }
}
