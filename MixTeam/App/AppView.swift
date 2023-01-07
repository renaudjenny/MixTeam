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
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(send: App.Action.tabSelected)) {
                // TODO: content should be replaced with a subview with its own store
                NavigationView {
                    content
                        .listStyle(.plain)
                        .tag(App.Tab.composition)
                }
                .tabItem {
                    Label("Composition", systemImage: "person.2.crop.square.stack")
                }
                ScoreboardView(store: store.scope(state: \.scores, action: App.Action.scores))
                    .tag(App.Tab.scoreboard)
                SettingsView(store: store.scope(state: \.settings, action: App.Action.settings))
                    .tag(App.Tab.settings)
            }
            .task { viewStore.send(.task) }
        }
        .navigationViewStyle(.stack)
    }

    private var legacyBody: some View {
        WithViewStore(store) { $0.status } content: { viewStore in
            NavigationView {
                content
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
            .sheet(isPresented: $isScoreboardPresented) {
                ScoreboardView(store: store.scope(state: \.scores, action: App.Action.scores))
            }
            .sheet(isPresented: $isAboutPresented) {
                aboutView
            }
            .task { viewStore.send(.task) }
        }
        .navigationViewStyle(.stack)
    }

    private var content: some View {
        WithViewStore(store, observe: \.status) { viewStore in
            switch viewStore.state {
            case .loading:
                ProgressView("Loading content from saved data")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded:
                CompositionView(store: store.scope(state: \.composition, action: App.Action.composition))
            case let .error(description):
                errorCardView(description: description)
            }
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

    private func errorCardView(description: String) -> some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(description)
                Button { viewStore.send(.task, animation: .default) } label: {
                    Text("Retry")
                }
                .buttonStyle(.dashed(color: MTColor.strawberry))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundAndForeground(color: .strawberry)
        }
    }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(store: .preview)
        AppView(store: Store(
            initialState: App.State(),
            reducer: App()
                .dependency(\.appPersistence.load, {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    throw PersistenceError.notFound
                })
        ))
        .previewDisplayName("App View With Error")
    }
}

extension Store where State == App.State, Action == App.Action {
    static var preview: Self {
        Self(initialState: .example, reducer: App())
    }
}
#endif
