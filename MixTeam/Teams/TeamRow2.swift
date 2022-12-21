import ComposableArchitecture
import SwiftUI

struct TeamRow1: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: Team.State.ID
        var row: Row = .loading
    }

    enum Row: Equatable {
        case loading
        case loaded(team: Team.State)
        case error(description: String)
    }

    enum Action: Equatable {
        case load
        case loaded(TaskResult<Team.State>)
        case team(Team.Action)
    }

    @Dependency(\.appPersistence.team) var teamPersistence

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .load:
                return .task { [state] in
                    guard let team = try await teamPersistence.load()[id: state.id]
                    else { throw PersistenceError.notFound }
                    return await .loaded(TaskResult { team })
                }
            case let .loaded(result):
                switch result {
                case let .success(team):
                    state.row = .loaded(team: team)
                    return .none
                case let .failure(error):
                    state.row = .error(description: error.localizedDescription)
                    return .none
                }
            case .team:
                return .none
            }
        }
        Scope(state: \.row, action: /Action.team) {
            EmptyReducer()
                .ifCaseLet(/Row.loaded, action: /.self) {
                    Team()
                }
        }
    }
}

struct TeamRowView: View {
    let store: StoreOf<TeamRow1>

    var body: some View {
        SwitchStore(store.scope(state: \.row, action: TeamRow1.Action.team)) {
            CaseLet(state: /TeamRow1.Row.loading) { (_: Store<Void, Team.Action>) in
                loadingView
            }
            CaseLet(state: /TeamRow1.Row.loaded) { (store: Store<Team.State, Team.Action>) in
                TeamRow(store: store)
            }
            CaseLet(state: /TeamRow1.Row.error) { (store: Store<String, Team.Action>) in
                WithViewStore(store) { viewStore in
                    Text(viewStore.description)
                }
            }
        }
    }

    private var loadingView: some View {
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

extension TeamRow1.State: Codable {
    enum CodingKeys: CodingKey {
        case id
    }
}
