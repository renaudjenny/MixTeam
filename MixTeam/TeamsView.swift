import SwiftUI

struct TeamsView: View {
    @ObservedObject var viewModel = TeamsViewModel()

    var body: some View {
        List {
            ForEach(viewModel.teams, content: teamRow)
        }
    }

    private func teamRow(team: Team) -> some View {
        Text(team.name)
    }
}

class TeamsHostingController: UIHostingController<TeamsView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: TeamsView())
    }
}
