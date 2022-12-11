import ComposableArchitecture
import Foundation

struct Round: ReducerProtocol {
    struct State: Identifiable, Equatable {
        let id: UUID
        var name: String
        var scores: IdentifiedArrayOf<Score.State> = []
    }

    enum Action: Equatable {
        case nameUpdated(String)
        case score(id: Score.State.ID, action: Score.Action)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .nameUpdated(name):
                state.name = name
                return .none
            case let .score(id: id, action: .remove):
                state.scores.remove(id: id)
                return .none
            case .score:
                return .none
            }
        }
        .forEach(\.scores, action: /Round.Action.score) {
            Score()
        }
    }
}

extension Round.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case scores
    }
}

extension Array where Element == Round.State {
    #if DEBUG
    static let mock: Self = {
        guard let thirdTeamID = UUID(uuidString: "21E5DDC4-7EDD-4F54-8DFA-B20BC396A12B"),
              let round1ID = UUID(uuidString: "D52863B0-B133-4380-A824-378839C8E996"),
              let round2ID = UUID(uuidString: "1D698816-025B-4E6A-907D-BEDF1BFB43C7"),
              let round3ID = UUID(uuidString: "0EA3AEDB-E598-4240-81DC-709D79E96783"),
              let round4ID = UUID(uuidString: "9FD2F46F-1A0D-4CA6-80ED-91A012C2D56E"),
              let score1ID = UUID(uuidString: "0EA5CA32-C3CA-47F9-AFAD-8F8CE505C9FC"),
              let score2ID = UUID(uuidString: "40112F6E-CAE8-4BF9-B405-573D7CBA7520"),
              let score3ID = UUID(uuidString: "3B83262E-6156-45DA-8AE6-B356C4100B43"),
              let score4ID = UUID(uuidString: "B002E47D-018E-4857-ACE2-82D4B1392B96"),
              let score5ID = UUID(uuidString: "1B57799F-301E-45DB-91E9-2CEF4E0EAD5E"),
              let score6ID = UUID(uuidString: "9B429204-816B-4F84-BC82-C324534BBE65"),
              let score7ID = UUID(uuidString: "3EA1E48C-E220-4C67-B670-618D96B985A2"),
              let score8ID = UUID(uuidString: "B3791F8A-C549-41F8-B505-99891496DD87"),
              let score9ID = UUID(uuidString: "3623C100-C8B9-4DA4-9D56-2FDE37601B8E")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        let team1: Team.State = App.State.example.teams[1]
        let team2: Team.State = App.State.example.teams[2]
        let team3 = Team.State(
            id: thirdTeamID,
            name: "The team who had no name",
            color: .strawberry,
            image: .hippo,
            players: []
        )

        return [
            Round.State(
                id: round1ID,
                name: "Round 1",
                scores: [
                    Score.State(id: score1ID, teamID: team1.id, points: 0, accumulatedPoints: 0),
                    Score.State(id: score2ID, teamID: team2.id, points: 20, accumulatedPoints: 20),
                ]
            ),
            Round.State(
                id: round2ID,
                name: "Round 2",
                scores: [
                    Score.State(id: score3ID, teamID: team1.id, points: 10, accumulatedPoints: 10),
                    Score.State(id: score4ID, teamID: team2.id, points: 20, accumulatedPoints: 40),
                ]
            ),
            Round.State(
                id: round3ID,
                name: "Round 3",
                scores: [
                    Score.State(id: score5ID, teamID: team1.id, points: 10, accumulatedPoints: 30),
                    Score.State(id: score6ID, teamID: team2.id, points: 50, accumulatedPoints: 90),
                ]
            ),
            Round.State(
                id: round4ID,
                name: "Round 4",
                scores: [
                    Score.State(id: score7ID, teamID: team1.id, points: 10, accumulatedPoints: 40),
                    Score.State(id: score8ID, teamID: team2.id, points: 50, accumulatedPoints: 140),
                    Score.State(id: score9ID, teamID: team3.id, points: 15, accumulatedPoints: 15),
                ]
            ),
        ]
    }()
    #endif
}
