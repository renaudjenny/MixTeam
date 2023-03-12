#if DEBUG
import Foundation

// swiftlint:disable function_body_length
public func addV2PersistedData() {
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
