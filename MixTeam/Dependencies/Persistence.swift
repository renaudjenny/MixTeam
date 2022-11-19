import Dependencies
import IdentifiedCollections
import Foundation
import XCTestDynamicOverlay

private let appStateKey = "app-state"

private struct PersistenceSaveDependencyKey: DependencyKey {
    static var liveValue = { (state: App.State) in
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: appStateKey)
    }
    static var testValue: (App.State) -> Void = XCTUnimplemented("Save App State non implemented")
}
extension DependencyValues {
    var save: (App.State) -> Void {
        get { self[PersistenceSaveDependencyKey.self] }
        set { self[PersistenceSaveDependencyKey.self] = newValue }
    }
}

private struct PersistenceLoadDependencyKey: DependencyKey {
    static var liveValue: App.State {
        guard let data = UserDefaults.standard.data(forKey: appStateKey) else {
            guard let migratedData = migratedData else { return .example }
            UserDefaults.standard.removeObject(forKey: "teams")
            UserDefaults.standard.removeObject(forKey: "Scores.rounds")
            if let data = try? JSONEncoder().encode(migratedData) {
                UserDefaults.standard.set(data, forKey: appStateKey)
            }
            return migratedData
        }
        return (try? JSONDecoder().decode(App.State.self, from: data)) ?? .example
    }
    static var testValue: App.State {
        XCTFail("Load App State non implemented")
        return App.State()
    }

    static var migratedData: App.State? {
        struct DprPlayer: Codable, Identifiable, Hashable {
            var id = UUID()
            var name: String = ""
            var imageIdentifier: ImageIdentifier
        }

        struct DprTeam: Codable, Identifiable, Hashable {
            var id = UUID()
            var name: String = ""
            var colorIdentifier: ColorIdentifier = .gray
            var imageIdentifier: ImageIdentifier = .unknown
            var players: [DprPlayer] = []

            var state: Team.State {
                Team.State(
                    id: id,
                    name: name,
                    colorIdentifier: colorIdentifier,
                    imageIdentifier: imageIdentifier,
                    players: IdentifiedArrayOf(uniqueElements: players.map { Player.State(
                        id: $0.id,
                        name: $0.name,
                        image: $0.imageIdentifier,
                        isStanding: false,
                        dprColor: colorIdentifier,
                        color: colorIdentifier.mtColor
                    ) })
                )
            }

            var standing: Standing.State {
                Standing.State(players: IdentifiedArrayOf(uniqueElements: players.map { Player.State(
                    id: $0.id,
                    name: $0.name,
                    image: $0.imageIdentifier,
                    isStanding: true,
                    dprColor: .gray,
                    color: colorIdentifier.mtColor
                )}))
            }
        }

        struct DprRound: Identifiable, Codable, Hashable {
            var name: String
            var scores: [DprScore]
            var id = UUID()
        }

        struct DprScore: Identifiable, Codable, Hashable {
            var team: DprTeam
            var points: Int
            var id: DprTeam.ID { team.id }
        }

        func roundStates(rounds: [DprRound]) -> [Round.State] {
            rounds.reduce([]) { result, round in
                let state = Round.State(
                    id: round.id,
                    name: round.name,
                    scores: IdentifiedArrayOf(uniqueElements: round.scores.map { score in Score.State(
                        id: UUID(),
                        team: score.team.state,
                        points: score.points,
                        accumulatedPoints: score.points + result.reduce(0) { result, round in
                            result + round.scores.filter { $0.team.id == score.team.id }.map(\.points).reduce(0, +)
                        }
                    ) })
                )

                return result + [state]
            }
        }

        let teamsData = UserDefaults.standard.data(forKey: "teams")
        let teams = teamsData.flatMap { (try? JSONDecoder().decode([DprTeam].self, from: $0)) }

        let roundsData = UserDefaults.standard.string(forKey: "Scores.rounds")?.data(using: .utf8)
        let rounds = roundsData.flatMap { (try? JSONDecoder().decode([DprRound].self, from: $0)) }

        if let teams, let rounds {
            let standing = teams.first?.standing ?? Standing.State()
            let teams = IdentifiedArrayOf(uniqueElements: teams.dropFirst().map(\.state))
            let rounds: IdentifiedArrayOf<Round.State> = IdentifiedArrayOf(uniqueElements: roundStates(rounds: rounds))
            let scores = Scores.State(teams: teams, rounds: rounds)

            return App.State(
                standing: standing,
                teams: teams,
                _scores: scores
            )
        } else if let teams {
            let standing = teams.first?.standing ?? Standing.State()
            let teams = IdentifiedArrayOf(uniqueElements: teams.dropFirst().map(\.state))
            return App.State(standing: standing, teams: teams)
        } else if let rounds {
            let rounds: IdentifiedArrayOf<Round.State> = IdentifiedArrayOf(uniqueElements: roundStates(rounds: rounds))
            return App.State(_scores: Scores.State(teams: [], rounds: rounds))
        } else {
            return nil
        }
    }
}

extension DependencyValues {
    var loaded: App.State {
        get { self[PersistenceLoadDependencyKey.self] }
        set { self[PersistenceLoadDependencyKey.self] = newValue }
    }
}

private extension ColorIdentifier {
    var mtColor: MTColor {
        switch self {
        case .yellow: return .leather
        case .orange: return .citrus
        case .red: return .strawberry
        case .pink: return .duck
        case .purple: return .lilac
        case .blue: return .bluejeans
        case .green: return .grass
        case .gray: return .aluminium
        }
    }
}
