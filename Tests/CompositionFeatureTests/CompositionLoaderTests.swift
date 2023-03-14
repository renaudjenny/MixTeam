import Combine
import ComposableArchitecture
import CompositionFeature
import LoaderCore
import XCTest

@MainActor
final class CompositionLoaderTests: XCTestCase {
    func testUpdate() async {
        let store = TestStore(initialState: .loadingCard, reducer: CompositionLoader()) { dependencies in
            dependencies.teamPersistence.load = { .example }
            dependencies.teamPersistence.publisher = {
                Result.Publisher(.success(.example)).eraseToAnyPublisher().values
            }
            dependencies.playerPersistence.load = { .example }
            dependencies.playerPersistence.publisher = {
                Result.Publisher(.success(.example)).eraseToAnyPublisher().values
            }
        }

        await store.send(.loadingCard(.task))
        let expectedState: Composition.State = Composition.State(teams: .example, standing: .example)
        await store.receive(.update(.success(expectedState))) {
            $0 = .loaded(expectedState)
        }
        await store.receive(.update(.success(expectedState)))
        await store.receive(.update(.success(expectedState)))
    }

    func testReloadOnError() async {
        let store = TestStore(initialState: .errorCard(ErrorCard.State(description: "Test error")), reducer: CompositionLoader()) { dependencies in
            dependencies.teamPersistence.load = { .example }
            dependencies.playerPersistence.load = { .example }
        }

        await store.send(.errorCard(.reload)) {
            $0 = .loadingCard
        }
        let expectedState: Composition.State = Composition.State(teams: .example, standing: .example)
        await store.receive(.update(.success(expectedState))) {
            $0 = .loaded(expectedState)
        }
    }
}
