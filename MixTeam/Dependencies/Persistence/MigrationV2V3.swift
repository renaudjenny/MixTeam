import IdentifiedCollections
import Foundation

var migratedData: AppData.State? {
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
                color: colorIdentifier.mtColor,
                image: imageIdentifier.mtImage,
                players: IdentifiedArrayOf(uniqueElements: players.map { Player.State(
                    id: $0.id,
                    name: $0.name,
                    image: $0.imageIdentifier.mtImage,
                    color: colorIdentifier.mtColor,
                    isStanding: false
                ) })
            )
        }

        var standing: Standing.State {
            Standing.State(
                players: IdentifiedArrayOf(uniqueElements: players.map { Player.State(
                    id: $0.id,
                    name: $0.name,
                    image: $0.imageIdentifier.mtImage,
                    color: colorIdentifier.mtColor,
                    isStanding: true
                )})
            )
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

    if let teams, let rounds, let standing = teams.first?.standing {
        let teams = IdentifiedArrayOf(uniqueElements: teams.dropFirst().map(\.state))
        let rounds: IdentifiedArrayOf<Round.State> = IdentifiedArrayOf(uniqueElements: roundStates(rounds: rounds))
        let scores = Scores.State(teams: teams, rounds: rounds)
        let composition = Composition.State(teams: teams, standing: standing)

        return AppData.State(teams: teams, composition: composition, scores: scores)
    } else if let teams, let standing = teams.first?.standing {
        let teams = IdentifiedArrayOf(uniqueElements: teams.dropFirst().map(\.state))
        let composition = Composition.State(teams: teams, standing: standing)
        return AppData.State(teams: teams, composition: composition)
    } else {
        return nil
    }
}

private enum ColorIdentifier: String, Codable {
    case yellow
    case orange
    case red
    case pink
    case purple
    case blue
    case green
    case gray

    var mtColor: MTColor {
        switch self {
        case .yellow: return .leather
        case .orange: return .peach
        case .red: return .strawberry
        case .pink: return .duck
        case .purple: return .lilac
        case .blue: return .bluejeans
        case .green: return .conifer
        case .gray: return .aluminium
        }
    }
}

private enum ImageIdentifier: String, Codable {
    case elephant = "elephant"
    case koala = "koala"
    case panda = "panda"
    case octopus = "octopus"
    case lion = "lion"
    case hippo = "hippo"

    case girl = "girl"
    case woman = "woman"
    case jack = "jack"
    case santa = "santa"
    case clown = "clown"
    case pirate = "pirate"

    case unknown = ""

    var mtImage: MTImage {
        switch self {
        case .elephant: return .elephant
        case .koala: return .koala
        case .panda: return .panda
        case .octopus: return .octopus
        case .lion: return .lion
        case .hippo: return .hippo
        case .girl: return .amelie
        case .woman: return .lara
        case .jack: return .jack
        case .santa: return .santa
        case .clown: return .clown
        case .pirate: return .pirate
        case .unknown: return .unknown
        }
    }
}
