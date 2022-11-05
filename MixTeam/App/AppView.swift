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
            List {
                Group {
                    header
                    StandingView(store: store.scope(state: \.standing, action: App.Action.standing))
                    mixTeamButton
                    ForEachStore(store.scope(state: \.teams, action: App.Action.team), content: TeamRow.init)
                        .listRowBackground(Color.clear)
                    addTeamButton
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.grouped)
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
            .sheet(isPresented: $isScoreboardPresented) {
                ScoreboardView(store: store.scope(state: \.scores, action: App.Action.scores))
            }
            .sheet(isPresented: $isAboutPresented) {
                aboutView
            }
            .task { viewStore.send(.loadState) }
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
        .listRowBackground(Color.clear)
        .padding(.vertical)
    }

    private var scoreboardButton: some View {
        Button { isScoreboardPresented = true } label: {
            Image(systemName: "list.bullet.rectangle")
                .resizable()
        }
        .frame(width: buttonSize.width, height: buttonSize.height)
        .modifier(Shadow())
        .buttonStyle(DashedButtonStyle(color: .purple))
        .accessibility(label: Text("Display scoreboard"))
    }

    private var aboutButton: some View {
        Button { isAboutPresented = true } label: {
            Image(systemName: "cube.box")
                .resizable()
        }
        .frame(width: buttonSize.width, height: buttonSize.height)
        .modifier(Shadow())
        .buttonStyle(DashedButtonStyle(color: .gray))
        .accessibility(label: Text("About"))
    }

    private var mixTeamButton: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.mixTeam, animation: .easeInOut) } label: {
                HStack {
                    Image(systemName: "shuffle")
                    Text("Mix Team")
                }
                .frame(maxWidth: .infinity, minHeight: 30)
            }
            .buttonStyle(DashedButtonStyle(color: .red))
            .padding(.horizontal)
            .accessibility(label: Text("Mix Team"))
            .listRowBackground(Color.clear)
        }
    }

    private var addTeamButton: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.addTeam, animation: .easeInOut) } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add a new Team")
                }.frame(maxWidth: .infinity)
            }
            .buttonStyle(DashedButtonStyle(color: .red))
            .padding()
            .accessibility(label: Text("Add Team"))
            .listRowBackground(Color.clear)
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
