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
                    addTeamButton
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .backgroundAndForeground(color: .aluminium)
            .frame(maxWidth: 800)
            .alert(store.scope(state: \.notEnoughTeamsAlert), dismiss: .dismissNotEnoughTeamsAlert)
            .sheet(isPresented: viewStore.binding(
                get: \.isEditTeamSheetPresented,
                send: App.Action.setEditTeamSheet(isPresented:)
            )) {
                IfLetStore(store.scope(state: \.editedTeam, action: App.Action.editedTeam)) { store in
                    EditTeamView(store: store)
                }
            }
            .sheet(isPresented: viewStore.binding(
                get: \.isEditPlayerSheetPresented,
                send: App.Action.setEditPlayerSheet(isPresented:)
            )) {
                IfLetStore(store.scope(state: \.editedPlayer, action: App.Action.editedPlayer)) { store in
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
    }

    private var scoreboardButton: some View {
        Button { isScoreboardPresented = true } label: {
            Label { Text("Display scoreboard") } icon: {
                Image(systemName: "list.bullet.rectangle")
                    .resizable()
            }
        }
        .labelStyle(.iconOnly)
        .frame(width: buttonSize.width, height: buttonSize.height)
        .buttonStyle(DashedButtonStyle(color: .aluminium))
    }

    private var aboutButton: some View {
        Button { isAboutPresented = true } label: {
            Image(systemName: "cube.box")
                .resizable()
        }
        .frame(width: buttonSize.width, height: buttonSize.height)
        .buttonStyle(DashedButtonStyle(color: .aluminium))
        .accessibility(label: Text("About"))
    }

    private var mixTeamButton: some View {
        WithViewStore(store) { viewStore in
            Button { viewStore.send(.mixTeam, animation: .easeInOut) } label: {
                Label("Mix Team", systemImage: "shuffle")
                    .frame(maxWidth: .infinity, minHeight: 30)
            }
            .buttonStyle(DashedButtonStyle(color: .aluminium))
            .listRowBackground(LinearGradient(
                colors: [
                    .gray,
                    viewStore.teams.first?.colorIdentifier.color(for: colorScheme) ?? .gray,
                ],
                startPoint: .top,
                endPoint: .bottom
            ))
        }
    }

    private var addTeamButton: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.addTeam, animation: .easeInOut) } label: {
                Label("Add a new Team", systemImage: "plus")
                    .frame(maxWidth: .infinity, minHeight: 30)
            }
            .buttonStyle(DashedButtonStyle(color: .aluminium))
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
                .dashedCardStyle()
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
