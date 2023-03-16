import ArchivesFeature
import ComposableArchitecture
import LoaderCore
import Models
import TeamsFeature
import XCTest

@MainActor
final class ArchivesTest: XCTestCase {
    func testUpdate() async {
        let store = TestStore(initialState: .loadingCard, reducer: Archives()) { dependencies in
            dependencies.teamPersistence.load = { self.persistedExampleOfArchived }
            dependencies.teamPersistence.publisher = {
                Result.Publisher(.success(self.persistedExampleOfArchived)).eraseToAnyPublisher().values
            }
            dependencies.playerPersistence.load = { .example }
        }

        await store.send(.loadingCard(.task))
        let rows = IdentifiedArrayOf(uniqueElements: self.exampleOfArchived.map { ArchiveRow.State(team: $0) })
        await store.receive(.update(.success(self.exampleOfArchived))) {
            $0 = .loaded(rows: rows)
        }
        await store.receive(.update(.success(self.exampleOfArchived)))
    }

    func testReloadOnError() async {
        let store = TestStore(initialState: .errorCard(ErrorCard.State(description: "Test error")), reducer: Archives()) { dependencies in
            dependencies.teamPersistence.load = { self.persistedExampleOfArchived }
            dependencies.playerPersistence.load = { .example }
        }

        await store.send(.errorCard(.reload)) {
            $0 = .loadingCard
        }
        let rows = IdentifiedArrayOf(uniqueElements: self.exampleOfArchived.map { ArchiveRow.State(team: $0) })
        await store.receive(.update(.success(self.exampleOfArchived))) {
            $0 = .loaded(rows: rows)
        }
    }

    private var persistedExampleOfArchived: IdentifiedArrayOf<PersistedTeam> {
        IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<PersistedTeam>.example.map {
            var team = $0
            team.isArchived = true
            return team
        })
    }

    private var exampleOfArchived: IdentifiedArrayOf<Team.State> {
        IdentifiedArrayOf(uniqueElements: IdentifiedArrayOf<Team.State>.example.map {
            var team = $0
            team.isArchived = true
            return team
        })
    }
}
