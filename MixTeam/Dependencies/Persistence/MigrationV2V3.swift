import IdentifiedCollections
import Foundation

var migratedData: App.State? {
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

        return App.State(teams: teams, composition: composition, scores: scores)
    } else if let teams, let standing = teams.first?.standing {
        let teams = IdentifiedArrayOf(uniqueElements: teams.dropFirst().map(\.state))
        let composition = Composition.State(teams: teams, standing: standing)
        return App.State(teams: teams, composition: composition)
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

#if DEBUG
func addV2PersistedData() {
    let teamsJSON = """
    [{
        "colorIdentifier": "gray",
        "id": "D6C7FA85-8DA0-45B7-8688-3D3390EACF05",
        "imageIdentifier": "",
        "name": "Players standing for a team",
        "players": [{
            "id": "87C3FB43-28C8-488A-A629-BC230594DF8D",
            "name": "CJ",
            "imageIdentifier": "clown"
        }, {
            "id": "B846B460-1600-4C41-98BF-CCA7BA65FD5D",
            "name": "Alice",
            "imageIdentifier": "girl"
        }]
    }, {
        "colorIdentifier": "red",
        "id": "00E9D827-9FAD-4686-83F2-FAD24D2531A2",
        "imageIdentifier": "koala",
        "name": "Red Koala",
        "players": [{
            "id": "2F77B05A-7B0C-4028-855C-A8A6A72D764B",
            "name": "José",
            "imageIdentifier": "santa"
        }, {
            "id": "02030543-B2FF-4E3F-BB4D-7CC3E87AEDED",
            "name": "Amelia",
            "imageIdentifier": "girl"
        }]
    }, {
        "colorIdentifier": "purple",
        "id": "98DBAF6C-685D-461F-9F81-E5E1E003B9AA",
        "imageIdentifier": "elephant",
        "name": "Purple Elephant",
        "players": [{
            "id": "CF6A4A0F-54C2-4CF0-B479-523D229EECFF",
            "name": "Mathilde",
            "imageIdentifier": "jack"
        }]
    }, {
        "colorIdentifier": "blue",
        "id": "6634515C-19C9-47DF-8B2B-036736F9AEA9",
        "imageIdentifier": "lion",
        "name": "Blue Lion",
        "players": [{
            "id": "A2BDCB2F-6A7A-4BA3-B166-077D74389588",
            "name": "Jack",
            "imageIdentifier": "jack"
        }]
    }]
    """
    UserDefaults.standard.set(teamsJSON.data(using: .utf8), forKey: "teams")

    let scoresJSON = """
    [{
        "name": "Round 1",
        "id": "17385066-AEEE-40AA-A9C2-C369BBD6D606",
        "scores": [{
            "team": {
                "colorIdentifier": "red",
                "id": "00E9D827-9FAD-4686-83F2-FAD24D2531A2",
                "imageIdentifier": "koala",
                "name": "Red Koala",
                "players": [{
                    "id": "2F77B05A-7B0C-4028-855C-A8A6A72D764B",
                    "name": "José",
                    "imageIdentifier": "santa"
                }, {
                    "id": "02030543-B2FF-4E3F-BB4D-7CC3E87AEDED",
                    "name": "Amelia",
                    "imageIdentifier": "girl"
                }]
            },
            "points": 10
        }, {
            "team": {
                "colorIdentifier": "purple",
                "id": "98DBAF6C-685D-461F-9F81-E5E1E003B9AA",
                "imageIdentifier": "elephant",
                "name": "Purple Elephant",
                "players": [{
                    "id": "CF6A4A0F-54C2-4CF0-B479-523D229EECFF",
                    "name": "Mathilde",
                    "imageIdentifier": "jack"
                }]
            },
            "points": 20
        }, {
            "team": {
                "colorIdentifier": "blue",
                "id": "6634515C-19C9-47DF-8B2B-036736F9AEA9",
                "imageIdentifier": "lion",
                "name": "Blue Lion",
                "players": [{
                    "id": "A2BDCB2F-6A7A-4BA3-B166-077D74389588",
                    "name": "Jack",
                    "imageIdentifier": "jack"
                }]
            },
            "points": 30
        }, {
            "team": {
                "colorIdentifier": "red",
                "id": "E955EBAD-6564-4907-A0D3-9B5F977D88A3",
                "imageIdentifier": "panda",
                "name": "Red Panda",
                "players": []
            },
            "points": 40
        }]
    }, {
        "name": "Round 2",
        "id": "35DFB56A-730C-476B-85E2-470589275AD3",
        "scores": [{
            "team": {
                "colorIdentifier": "red",
                "id": "00E9D827-9FAD-4686-83F2-FAD24D2531A2",
                "imageIdentifier": "koala",
                "name": "Red Koala",
                "players": [{
                    "id": "2F77B05A-7B0C-4028-855C-A8A6A72D764B",
                    "name": "José",
                    "imageIdentifier": "santa"
                }, {
                    "id": "02030543-B2FF-4E3F-BB4D-7CC3E87AEDED",
                    "name": "Amelia",
                    "imageIdentifier": "girl"
                }]
            },
            "points": 20
        }, {
            "team": {
                "colorIdentifier": "purple",
                "id": "98DBAF6C-685D-461F-9F81-E5E1E003B9AA",
                "imageIdentifier": "elephant",
                "name": "Purple Elephant",
                "players": [{
                    "id": "CF6A4A0F-54C2-4CF0-B479-523D229EECFF",
                    "name": "Mathilde",
                    "imageIdentifier": "jack"
                }]
            },
            "points": 30
        }, {
            "team": {
                "colorIdentifier": "blue",
                "id": "6634515C-19C9-47DF-8B2B-036736F9AEA9",
                "imageIdentifier": "lion",
                "name": "Blue Lion",
                "players": [{
                    "id": "A2BDCB2F-6A7A-4BA3-B166-077D74389588",
                    "name": "Jack",
                    "imageIdentifier": "jack"
                }]
            },
            "points": 40
        }, {
            "team": {
                "colorIdentifier": "red",
                "id": "E955EBAD-6564-4907-A0D3-9B5F977D88A3",
                "imageIdentifier": "panda",
                "name": "Red Panda",
                "players": []
            },
            "points": 50
        }]
    }, {
        "name": "Round with custom name",
        "id": "B865E373-FCD6-40D7-807A-67E53B73A2F2",
        "scores": [{
            "team": {
                "colorIdentifier": "red",
                "id": "00E9D827-9FAD-4686-83F2-FAD24D2531A2",
                "imageIdentifier": "koala",
                "name": "Red Koala",
                "players": [{
                    "id": "2F77B05A-7B0C-4028-855C-A8A6A72D764B",
                    "name": "José",
                    "imageIdentifier": "santa"
                }, {
                    "id": "02030543-B2FF-4E3F-BB4D-7CC3E87AEDED",
                    "name": "Amelia",
                    "imageIdentifier": "girl"
                }]
            },
            "points": 1
        }, {
            "team": {
                "colorIdentifier": "purple",
                "id": "98DBAF6C-685D-461F-9F81-E5E1E003B9AA",
                "imageIdentifier": "elephant",
                "name": "Purple Elephant",
                "players": [{
                    "id": "CF6A4A0F-54C2-4CF0-B479-523D229EECFF",
                    "name": "Mathilde",
                    "imageIdentifier": "jack"
                }]
            },
            "points": 1
        }, {
            "team": {
                "colorIdentifier": "blue",
                "id": "6634515C-19C9-47DF-8B2B-036736F9AEA9",
                "imageIdentifier": "lion",
                "name": "Blue Lion",
                "players": [{
                    "id": "A2BDCB2F-6A7A-4BA3-B166-077D74389588",
                    "name": "Jack",
                    "imageIdentifier": "jack"
                }]
            },
            "points": 1
        }, {
            "team": {
                "colorIdentifier": "red",
                "id": "E955EBAD-6564-4907-A0D3-9B5F977D88A3",
                "imageIdentifier": "panda",
                "name": "Red Panda",
                "players": []
            },
            "points": 1
        }]
    }, {
        "name": "Round without panda",
        "id": "5DDA6293-EDA8-4BAB-82D7-5CD3CD43D2DF",
        "scores": [{
            "team": {
                "colorIdentifier": "red",
                "id": "00E9D827-9FAD-4686-83F2-FAD24D2531A2",
                "imageIdentifier": "koala",
                "name": "Red Koala",
                "players": [{
                    "id": "2F77B05A-7B0C-4028-855C-A8A6A72D764B",
                    "name": "José",
                    "imageIdentifier": "santa"
                }, {
                    "id": "02030543-B2FF-4E3F-BB4D-7CC3E87AEDED",
                    "name": "Amelia",
                    "imageIdentifier": "girl"
                }]
            },
            "points": 20
        }, {
            "team": {
                "colorIdentifier": "purple",
                "id": "98DBAF6C-685D-461F-9F81-E5E1E003B9AA",
                "imageIdentifier": "elephant",
                "name": "Purple Elephant",
                "players": [{
                    "id": "CF6A4A0F-54C2-4CF0-B479-523D229EECFF",
                    "name": "Mathilde",
                    "imageIdentifier": "jack"
                }]
            },
            "points": 10
        }, {
            "team": {
                "colorIdentifier": "blue",
                "id": "6634515C-19C9-47DF-8B2B-036736F9AEA9",
                "imageIdentifier": "lion",
                "name": "Blue Lion",
                "players": [{
                    "id": "A2BDCB2F-6A7A-4BA3-B166-077D74389588",
                    "name": "Jack",
                    "imageIdentifier": "jack"
                }]
            },
            "points": 1
        }]
    }]
    """
    UserDefaults.standard.set(scoresJSON, forKey: "Scores.rounds")
}
#endif
