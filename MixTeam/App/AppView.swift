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
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVStack {
                    header
                    StandingView(store: store.scope(state: \.standing, action: App.Action.standing))
                    mixTeamButton
                    ForEachStore(store.scope(state: \.teams, action: App.Action.team), content: TeamRow.init)
                    addTeamButton
                }
            }
            .frame(maxWidth: 800)
            .alert(store.scope(state: \.notEnoughTeamsAlert), dismiss: .dismissNotEnoughTeamsAlert)
            .sheet(isPresented: viewStore.binding(
                get: { $0.isEditTeamSheetPresented },
                send: { .setEditTeamSheetIsPresented($0) }
            )) {
                IfLetStore(store.scope(state: \.editedTeam, action: App.Action.teamEdited)) { store in
                    EditTeamView(store: store)
                }
            }
            .sheet(isPresented: viewStore.binding(
                get: { $0.isEditPlayerSheetPresented },
                send: { .setEditPlayerSheetIsPresented($0) }
            )) {
                IfLetStore(store.scope(state: \.editedPlayer, action: App.Action.playerEdited)) { store in
                    EditPlayerView(store: store)
                }
            }
            .background(Color.clear.sheet(isPresented: $isScoreboardPresented) {
                ScoreboardView(store: store.scope(state: \.scores, action: App.Action.scores))
            })
            .background(Color.clear.sheet(isPresented: $isAboutPresented) {
                aboutView
            })
            .task { viewStore.send(.loadTeams) }
        }
    }

    private var header: some View {
        HStack {
            scoreboardButton
            Spacer()
            Text("Mix Team")
                .font(.largeTitle)
                .fontWeight(.black)
            Spacer()
            aboutButton
        }
        .padding(.vertical)
    }

    private var scoreboardButton: some View {
        Button { isScoreboardPresented = true } label: {
            Image(systemName: "list.bullet.rectangle")
                .resizable()
                .padding(14)
        }
        .frame(width: buttonSize.width, height: buttonSize.height)
        .modifier(Shadow())
        .buttonStyle(MixTeamButtonStyle(color: .purple))
        .padding(.horizontal)
        .accessibility(label: Text("Display scoreboard"))
    }

    private var aboutButton: some View {
        Button { isAboutPresented = true } label: {
            Image(systemName: "cube.box")
                .resizable()
                .padding(12)
        }
        .frame(width: buttonSize.width, height: buttonSize.height)
        .modifier(Shadow())
        .buttonStyle(MixTeamButtonStyle(color: .gray))
        .padding(.horizontal)
        .accessibility(label: Text("About"))
    }

    private var mixTeamButton: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.mixTeam) } label: {
                HStack {
                    Image(systemName: "shuffle")
                    Text("Mix Team")
                }
            }
            .modifier(Shadow())
            .buttonStyle(MixTeamButtonStyle())
            .frame(height: 50)
            .padding(.horizontal)
            .accessibility(label: Text("Mix Team"))
        }
    }

    private var addTeamButton: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.addTeam) } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add a new Team")
                }.frame(maxWidth: .infinity)
            }
            .buttonStyle(CommonButtonStyle(color: .red))
            .padding()
            .accessibility(label: Text("Add Team"))
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
            Group {
                colorScheme == .light
                ? Color.gray.opacity(1/2)
                : Color.black.opacity(3/4)
            }
            .modifier(AddDashedCardStyle())
            .shadow(radius: 6)
        }
    }
}

#if DEBUG
struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppView(store: .preview)
            AppView(store: .preview)
                .environment(\.colorScheme, .dark)
        }
    }
}

extension StoreOf<App> {
    static var preview: StoreOf<App> {
        Store(initialState: .example, reducer: App())
    }
}
#endif
