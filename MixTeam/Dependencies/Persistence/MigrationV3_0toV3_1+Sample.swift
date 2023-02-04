import Dependencies
import Foundation
import IdentifiedCollections

// swiftlint:disable:next function_body_length
func addV3_0toV3_1PersistedData() throws {
    let teamJSON = """
    [{
        "image": "koala",
        "id": "00E9D827-9FAD-4686-83F2-FAD24D2531A2",
        "isArchived": false,
        "name": "Red Koala",
        "playerIDs": ["2F77B05A-7B0C-4028-855C-A8A6A72D764B", "02030543-B2FF-4E3F-BB4D-7CC3E87AEDED"],
        "color": "strawberry"
    }, {
        "image": "elephant",
        "id": "98DBAF6C-685D-461F-9F81-E5E1E003B9AA",
        "isArchived": false,
        "name": "Purple Elephant",
        "playerIDs": ["CF6A4A0F-54C2-4CF0-B479-523D229EECFF"],
        "color": "lilac"
    }, {
        "image": "lion",
        "id": "6634515C-19C9-47DF-8B2B-036736F9AEA9",
        "isArchived": false,
        "name": "Blue Lion",
        "playerIDs": ["A2BDCB2F-6A7A-4BA3-B166-077D74389588"],
        "color": "bluejeans"
    }]
    """
    let playerJSON = """
    [{
        "id": "2F77B05A-7B0C-4028-855C-A8A6A72D764B",
        "name": "José",
        "image": "santa"
    }, {
        "id": "02030543-B2FF-4E3F-BB4D-7CC3E87AEDED",
        "name": "Amelia",
        "image": "amelie"
    }, {
        "id": "CF6A4A0F-54C2-4CF0-B479-523D229EECFF",
        "name": "Mathilde",
        "image": "jack"
    }, {
        "id": "A2BDCB2F-6A7A-4BA3-B166-077D74389588",
        "name": "Jack",
        "image": "jack"
    }, {
        "id": "87C3FB43-28C8-488A-A629-BC230594DF8D",
        "name": "CJ",
        "image": "clown"
    }, {
        "id": "B846B460-1600-4C41-98BF-CCA7BA65FD5D",
        "name": "Alicia",
        "image": "warrior"
    }]
    """
    let appJSON = """
    {
        "teamIDs": [
            "00E9D827-9FAD-4686-83F2-FAD24D2531A2",
            "98DBAF6C-685D-461F-9F81-E5E1E003B9AA",
            "6634515C-19C9-47DF-8B2B-036736F9AEA9"
        ],
        "composition": {
            "teamIDs": [
                "00E9D827-9FAD-4686-83F2-FAD24D2531A2",
                "98DBAF6C-685D-461F-9F81-E5E1E003B9AA",
                "6634515C-19C9-47DF-8B2B-036736F9AEA9"
            ],
            "standing": {
                "playerIDs": ["87C3FB43-28C8-488A-A629-BC230594DF8D", "B846B460-1600-4C41-98BF-CCA7BA65FD5D"]
            }
        },
        "scores": {
            "rounds": [{
                "id": "17385066-AEEE-40AA-A9C2-C369BBD6D606",
                "name": "Round 1",
                "scores": [{
                    "id": "B7DBF773-D9D1-486B-9531-2EAACEC8ECBF",
                    "points": 10,
                    "teamID": "00E9D827-9FAD-4686-83F2-FAD24D2531A2"
                }, {
                    "id": "CAADCC53-FDED-4899-98A7-B635B73C28A1",
                    "points": 20,
                    "teamID": "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"
                }, {
                    "id": "0A4FE7EA-45BD-4B04-B064-617C7DD078D2",
                    "points": 30,
                    "teamID": "6634515C-19C9-47DF-8B2B-036736F9AEA9"
                }, {
                    "id": "626F92A0-BEBA-4D99-87B8-99C816D124FA",
                    "points": 40,
                    "teamID": "E955EBAD-6564-4907-A0D3-9B5F977D88A3"
                }]
            }, {
                "id": "35DFB56A-730C-476B-85E2-470589275AD3",
                "name": "Round 2",
                "scores": [{
                    "id": "E66C0CC0-2133-431F-897C-EB27B029A782",
                    "points": 20,
                    "teamID": "00E9D827-9FAD-4686-83F2-FAD24D2531A2"
                }, {
                    "id": "9DFECD7E-BB98-4BDA-AEB2-BA33C394E0CA",
                    "points": 30,
                    "teamID": "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"
                }, {
                    "id": "13417AE7-AF56-4EEB-80C8-1329492FDFB9",
                    "points": 40,
                    "teamID": "6634515C-19C9-47DF-8B2B-036736F9AEA9"
                }, {
                    "id": "880915CE-4B3A-4A3E-8A26-36E04F2F351B",
                    "points": 50,
                    "teamID": "E955EBAD-6564-4907-A0D3-9B5F977D88A3"
                }]
            }, {
                "id": "B865E373-FCD6-40D7-807A-67E53B73A2F2",
                "name": "Round with custom name",
                "scores": [{
                    "id": "22F7E0BA-7669-4707-8981-30912192719E",
                    "points": 1,
                    "teamID": "00E9D827-9FAD-4686-83F2-FAD24D2531A2"
                }, {
                    "id": "DAB62FAC-BB52-4964-850F-2532224A5C37",
                    "points": 1,
                    "teamID": "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"
                }, {
                    "id": "A4DDF989-D98E-488C-BED1-1D927DEBDCFA",
                    "points": 1,
                    "teamID": "6634515C-19C9-47DF-8B2B-036736F9AEA9"
                }, {
                    "id": "B4DD0C2F-634C-475A-96AA-9D0DEDECEA79",
                    "points": 1,
                    "teamID": "E955EBAD-6564-4907-A0D3-9B5F977D88A3"
                }]
            }, {
                "id": "5DDA6293-EDA8-4BAB-82D7-5CD3CD43D2DF",
                "name": "Round without panda",
                "scores": [{
                    "id": "98FA23D6-1792-424F-ABED-1276848F2F64",
                    "points": 20,
                    "teamID": "00E9D827-9FAD-4686-83F2-FAD24D2531A2"
                }, {
                    "id": "F08867B9-3C1E-4D24-A401-950CE24F5548",
                    "points": 10,
                    "teamID": "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"
                }, {
                    "id": "24417E61-C7DE-473E-96EE-4335B42437AE",
                    "points": 1,
                    "teamID": "6634515C-19C9-47DF-8B2B-036736F9AEA9"
                }]
            }]
        }
    }
    """
    guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    try teamJSON.data(using: .utf8)?.write(to: url.appendingPathComponent("MixTeamTeamV3_0_0", conformingTo: .json))
    try playerJSON.data(using: .utf8)?.write(to: url.appendingPathComponent("MixTeamPlayerV3_0_0", conformingTo: .json))
    try appJSON.data(using: .utf8)?.write(to: url.appendingPathComponent("MixTeamAppV3_0_0", conformingTo: .json))
}
