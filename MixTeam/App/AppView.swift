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
            NavigationView {
                List {
                    Group {
                        header
                        StandingView(store: store.scope(state: \.standing, action: App.Action.standing))
                        mixTeamButton
                        ForEachStore(store.scope(state: \.teams, action: App.Action.team), content: TeamRow.init)
                            .onDelete { viewStore.send(.deleteTeams($0), animation: .default) }
                        addTeamButton
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .backgroundAndForeground(color: .aluminium)
            }
            .listStyle(.plain)
            .alert(store.scope(state: \.notEnoughTeamsAlert), dismiss: .dismissNotEnoughTeamsAlert)
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
            }
            .buttonStyle(.dashed(color: .aluminium))
            .frame(maxWidth: .infinity)
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
