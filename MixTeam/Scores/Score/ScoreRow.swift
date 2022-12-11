import ComposableArchitecture
import SwiftUI

struct ScoreRow: View {
    let store: StoreOf<Score>
    @FocusState var focusedField: Score.State?

    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                switch viewStore.teamStatus {
                case .loading:
                    content(team: nil)
                        .task { viewStore.send(.loadTeam) }
                case let .loaded(team):
                    content(team: team)
                        .swipeActions {
                            Button(role: .destructive) { viewStore.send(.remove, animation: .default) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                case .error:
                    Text("ERROR!")
                        .frame(maxWidth: .infinity)
                }
            }
            .listRowSeparator(.hidden)
            .backgroundAndForeground(color: viewStore.teamStatus.color)
            .textFieldStyle(.roundedBorder)
            .redacted(reason: viewStore.teamStatus == .loading ? .placeholder : [])
        }
    }

    private func content(team: Team.State?) -> some View {
        WithViewStore(store) { viewStore in
            HStack {
                Image(mtImage: team?.image ?? .unknown)
                    .resizable()
                    .frame(maxWidth: 24, maxHeight: 24)
                Text(team?.name ?? "Placeholder team name")
                    .lineLimit(1)
                    .frame(maxWidth: 120, alignment: .leading)

                TextField("", text: viewStore.binding(\.$points).string, prompt: Text("123"))
                    .frame(maxWidth: 70)
                    .focused($focusedField, equals: viewStore.state)
                    .keyboardType(.numberPad)

                Spacer()

                Text("\(viewStore.accumulatedPoints)")
                    .bold()
                    .frame(maxWidth: 50, alignment: .trailing)
            }
        }
    }
}

private extension Score.TeamStatus {
    var color: MTColor {
        if case let .loaded(team) = self {
            return team.color
        } else {
            return .aluminium
        }
    }
}

#if DEBUG
struct ScoreRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ScoreRow(store: Store(initialState: .preview, reducer: Score()))
            ScoreRow(store: Store(initialState: .secondPreview, reducer: Score()))
            ScoreRow(store: Store(
                initialState: .loadingPreview,
                reducer: Score()
                    .dependency(\.appPersistence.team, .previewWithDelay)
            ))
            ScoreRow(store: Store(
                initialState: .loadingPreview,
                reducer: Score()
                    .dependency(\.appPersistence.team, .previewWithError)
            ))
        }
    }
}

extension Score.State {
    static var preview: Self {
        guard let id = UUID(uuidString: "8A74A892-2C3F-4BB4-A8B3-19C5B1E0AD84") else {
            fatalError("Cannot generate UUID from a defined UUID String")
        }
        let teamID = Team.State.preview.id
        return Score.State(id: id, teamID: teamID, points: 15, accumulatedPoints: 35, teamStatus: .loaded(.preview))
    }
    static var secondPreview: Self {
        guard let id = UUID(uuidString: "7C3E9E9F-31CE-462B-9894-08C699B13AD0") else {
            fatalError("Cannot generate UUID from a defined UUID String")
        }
        let teamID = Team.State.preview.id
        return Score.State(id: id, teamID: teamID, points: 25, accumulatedPoints: 350, teamStatus: .loaded(.preview))
    }
    static var loadingPreview: Self {
        guard let id = UUID(uuidString: "19DD415A-8769-473D-9F5C-308861274655") else {
            fatalError("Cannot generate UUID from a defined UUID String")
        }
        let teamID = Team.State.preview.id
        return Score.State(id: id, teamID: teamID, points: 1, accumulatedPoints: 10, teamStatus: .loading)
    }
}

private extension TeamPersistence {
    static let previewWithDelay = Self(load: {
        try await Task.sleep(nanoseconds: 1_000_000_000 * 2)
        return [.preview]
    })
    static let previewWithError = Self(load: {
        try await Task.sleep(nanoseconds: 1_000_000_000 * 2)
        struct PreviewError: Error {}
        throw PreviewError()
    })
}
#endif
