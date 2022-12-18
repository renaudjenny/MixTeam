import ComposableArchitecture
import SwiftUI
import RenaudJennyAboutView

struct AppView: View {
    let store: StoreOf<App>
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAboutPresented = false
    @State private var isScoreboardPresented = false
    private let buttonSize = CGSize(width: 60, height: 60)

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            NavigationView {
                List {
                    Group {
                        StandingView(store: store.scope(state: \.standing, action: App.Action.standing))
                        mixTeamButton
                        teams
                        addTeamButton
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .backgroundAndForeground(color: .aluminium)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Mix Team")
                            .font(.largeTitle)
                            .fontWeight(.black)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { isScoreboardPresented = true } label: {
                            Label { Text("Display scoreboard") } icon: {
                                Image(systemName: "list.bullet.rectangle")
                                    .resizable()
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { isAboutPresented = true } label: {
                            Image(systemName: "cube.box")
                                .resizable()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .alert(store.scope(state: \.notEnoughTeamsAlert), dismiss: .dismissNotEnoughTeamsAlert)
            .sheet(isPresented: $isScoreboardPresented) {
                ScoreboardView(store: store.scope(state: \.scores, action: App.Action.scores))
            }
            .sheet(isPresented: $isAboutPresented) {
                aboutView
            }
            .task { @MainActor in viewStore.send(.load) }
        }
    }

    private var mixTeamButton: some View {
        WithViewStore(store) { viewStore in
            Button { viewStore.send(.mixTeam, animation: .easeInOut) } label: {
                Label("Mix Team", systemImage: "shuffle")
            }
            .buttonStyle(.dashed(color: .aluminium))
            .frame(maxWidth: .infinity)
        }
    }

    private typealias TeamAction = (Team.State.ID, Team.Action)
    private typealias TeamsState = IdentifiedArrayOf<Team.State>

    private var teams: some View {
        WithViewStore(store.stateless) { viewStore in
            SwitchStore(store.scope(state: \.teams, action: App.Action.team(id:action:))) {
                CaseLet(state: /App.Teams.loading) { (_: Store<Void, TeamAction>) in
                    loadingView
                }
                CaseLet(state: /App.Teams.loaded) { (store: Store<TeamsState, TeamAction>) in
                    ForEachStore(store, content: TeamRow.init)
                        .onDelete { viewStore.send(.deleteTeams($0), animation: .default) }
                }
                CaseLet(state: /App.Teams.error) { (store: Store<String, TeamAction>) in
                    WithViewStore(store.actionless) { viewStore in
                        Text(viewStore.state)
                    }
                }
            }
        }
    }

    private var loadingView: some View {
        WithViewStore(store) { viewStore in
            let teamsCount = viewStore.teamIDs.count > 0 ? viewStore.teamIDs.count : 1
            ForEach(0..<teamsCount, id: \.self) { _ in
                HStack {
                    Image(mtImage: .unknown)
                        .resizable()
                        .frame(width: 48, height: 48)
                        .redacted(reason: .placeholder)
                    Text("Placeholder name")
                        .font(.title2)
                        .fontWeight(.black)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                        .redacted(reason: .placeholder)
                }
                .dashedCardStyle(color: .aluminium)
                .backgroundAndForeground(color: .aluminium)
            }
        }
    }

    private var addTeamButton: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.addTeam, animation: .easeInOut) } label: {
                Label("Add a new Team", systemImage: "plus")
            }
            .buttonStyle(DashedButtonStyle(color: .aluminium))
            .frame(maxWidth: .infinity)
        }
    }

    private var aboutView: some View {
        RenaudJennyAboutView.AboutView(appId: "id1526493495", isInModal: true) {
            Image(uiImage: #imageLiteral(resourceName: "Logo"))
                .cornerRadius(16)
                .padding()
                .padding(.top)
                .shadow(radius: 5)
        } background: {
            MTColor.aluminium.backgroundColor(scheme: colorScheme)
                .dashedCardStyle(color: MTColor.aluminium)
        }
    }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(store: .preview)
    }
}

extension Store where State == App.State, Action == App.Action {
    static var preview: Self {
        Self(initialState: .example, reducer: App())
    }
}
#endif
