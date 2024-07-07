import Assets
import ComposableArchitecture
import Models
import PersistenceCore
import SwiftUI
import TeamsFeature

public struct ScoreRow: View {
    @Bindable var store: StoreOf<Score>
    @FocusState var focusedField: Score.State?

    public init(store: StoreOf<Score>, focusedField: FocusState<Score.State?> = FocusState<Score.State?>()) {
        self.store = store
        self._focusedField = focusedField
    }

    public var body: some View {
        HStack {
            Image(mtImage: store.team.image)
                .resizable()
                .frame(maxWidth: 24, maxHeight: 24)
            Text(store.team.name)
                .lineLimit(1)
                .frame(maxWidth: 120, alignment: .leading)

            TextField("", text: $store.points.string, prompt: Text("123"))
                .frame(maxWidth: 70)
                .focused($focusedField, equals: store.state)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif

            Spacer()

            Text("\(store.accumulatedPoints)")
                .bold()
                .frame(maxWidth: 50, alignment: .trailing)
        }
        .swipeActions {
            Button(role: .destructive) { store.send(.remove, animation: .default) } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        #if os(iOS)
        .listRowSeparator(.hidden)
        #endif
        .backgroundAndForeground(color: store.team.color)
        .textFieldStyle(.roundedBorder)
    }

    private func content(team: Team.State?) -> some View {
        HStack {
            Image(mtImage: team?.image ?? .unknown)
                .resizable()
                .frame(maxWidth: 24, maxHeight: 24)
            Text(team?.name ?? "Placeholder team name")
                .lineLimit(1)
                .frame(maxWidth: 120, alignment: .leading)

            TextField("", text: $store.points.string, prompt: Text("123"))
                .frame(maxWidth: 70)
                .focused($focusedField, equals: store.state)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif

            Spacer()

            Text("\(store.accumulatedPoints)")
                .bold()
                .frame(maxWidth: 50, alignment: .trailing)
        }
    }
}

// TODO: Fix preview

//#if DEBUG
//struct ScoreRow_Previews: PreviewProvider {
//    static var previews: some View {
//        List {
//            ScoreRow(store: Store(initialState: .preview, reducer: Score()))
//            ScoreRow(store: Store(initialState: .secondPreview, reducer: Score()))
//            ScoreRow(store: Store(
//                initialState: .loadingPreview,
//                reducer: Score()
//                    .dependency(\.teamPersistence.load, TeamPersistence.previewWithDelay)
//            ))
//            ScoreRow(store: Store(
//                initialState: .loadingPreview,
//                reducer: Score()
//                    .dependency(\.teamPersistence.load, TeamPersistence.previewWithError)
//            ))
//        }
//    }
//}
//
//extension Score.State {
//    static var preview: Self {
//        guard let id = UUID(uuidString: "8A74A892-2C3F-4BB4-A8B3-19C5B1E0AD84") else {
//            fatalError("Cannot generate UUID from a defined UUID String")
//        }
//        return Score.State(id: id, team: .preview, points: 15, accumulatedPoints: 35)
//    }
//    static var secondPreview: Self {
//        guard let id = UUID(uuidString: "7C3E9E9F-31CE-462B-9894-08C699B13AD0") else {
//            fatalError("Cannot generate UUID from a defined UUID String")
//        }
//        return Score.State(id: id, team: .preview, points: 25, accumulatedPoints: 35)
//    }
//    static var loadingPreview: Self {
//        guard let id = UUID(uuidString: "19DD415A-8769-473D-9F5C-308861274655") else {
//            fatalError("Cannot generate UUID from a defined UUID String")
//        }
//        return Score.State(id: id, team: .preview, points: 1, accumulatedPoints: 10)
//    }
//}
//
//private extension TeamPersistence {
//    static let previewWithDelay: () async throws -> IdentifiedArrayOf<PersistedTeam> = {
//        try await Task.sleep(nanoseconds: 1_000_000_000 * 2)
//        let team = Team.State.preview
//        return [PersistedTeam(
//            id: team.id,
//            name: team.name,
//            color: team.color,
//            image: team.image,
//            playerIDs: team.players.map(\.id),
//            isArchived: team.isArchived
//        )]
//    }
//    static let previewWithError: () async throws -> IdentifiedArrayOf<PersistedTeam> = {
//        try await Task.sleep(nanoseconds: 1_000_000_000 * 2)
//        struct PreviewError: Error {}
//        throw PreviewError()
//    }
//}
//#endif
