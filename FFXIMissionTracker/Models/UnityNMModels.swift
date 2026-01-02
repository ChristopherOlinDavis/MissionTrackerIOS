//
//  UnityNMModels.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import Foundation

// MARK: - Unity NM Point Rewards
struct UNMPointRewards: Codable, Hashable {
    let sparks: Int
    let exp: Int
    let cp: Int
}

// MARK: - Unity NM Notable Reward
struct UNMNotableReward: Codable, Hashable, Identifiable {
    let item: String
    let url: String

    var id: String { item }
}

// MARK: - Ethereal Junction (for complex multi-map zones)
struct EtherealJunctionMap: Codable, Hashable {
    let map: Int
    let coords: [String]
}

// MARK: - Ethereal Junctions (can be simple array or complex with maps)
enum EtherealJunctions: Codable, Hashable {
    case simple([String])
    case complex([EtherealJunctionMap])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Try to decode as array of strings first
        if let simpleArray = try? container.decode([String].self) {
            self = .simple(simpleArray)
            return
        }

        // Otherwise decode as array of junction maps
        if let complexArray = try? container.decode([EtherealJunctionMap].self) {
            self = .complex(complexArray)
            return
        }

        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode ethereal junctions")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let array):
            try container.encode(array)
        case .complex(let array):
            try container.encode(array)
        }
    }

    var displayString: String {
        switch self {
        case .simple(let coords):
            return coords.joined(separator: ", ")
        case .complex(let maps):
            return maps.map { map in
                "Map \(map.map): \(map.coords.joined(separator: ", "))"
            }.joined(separator: " | ")
        }
    }
}

// MARK: - Unity Notorious Monster
struct UnityNotoriousMonster: Codable, Identifiable, Hashable {
    let level: Int
    let accolades: Int
    let nm: String
    let zone: String
    let category: String
    let etherealJunctions: EtherealJunctions
    let unityWarp: String
    let pointRewards: UNMPointRewards
    let notableRewards: [UNMNotableReward]

    var id: String { nm }

    var displayName: String { nm }

    var levelDisplay: String {
        "Lv. \(level)"
    }

    var accoladesDisplay: String {
        "\(accolades) Accolades"
    }

    var junctionsDisplay: String {
        etherealJunctions.displayString
    }

    // Coding keys for JSON mapping
    enum CodingKeys: String, CodingKey {
        case level
        case accolades
        case nm
        case zone
        case category
        case etherealJunctions = "ethereal_junctions"
        case unityWarp = "unity_warp"
        case pointRewards = "point_rewards"
        case notableRewards = "notable_rewards"
    }
}

// MARK: - Unity NM Metadata
struct UNMMetadata: Codable, Hashable {
    let totalCount: Int
    let levelRange: LevelRange
    let accoladeRange: AccoladeRange
    let categories: [String]

    struct LevelRange: Codable, Hashable {
        let min: Int
        let max: Int
    }

    struct AccoladeRange: Codable, Hashable {
        let min: Int
        let max: Int
    }

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case levelRange = "level_range"
        case accoladeRange = "accolade_range"
        case categories
    }
}

// MARK: - Unity NM Response
struct UnityNMResponse: Codable {
    let metadata: UNMMetadata
    let unityNotoriousMonsters: [UnityNotoriousMonster]

    enum CodingKeys: String, CodingKey {
        case metadata
        case unityNotoriousMonsters = "unity_notorious_monsters"
    }
}

// MARK: - Grouped Unity NM Data (for UI)
struct UNMCategoryGroup: Identifiable, Hashable {
    let name: String
    let nms: [UnityNotoriousMonster]

    var id: String { name }

    var displayName: String { name }

    var levelRange: String {
        guard let minLevel = nms.map({ $0.level }).min(),
              let maxLevel = nms.map({ $0.level }).max() else {
            return "Unknown"
        }
        return minLevel == maxLevel ? "Lv. \(minLevel)" : "Lv. \(minLevel)-\(maxLevel)"
    }

    var accoladeRange: String {
        guard let minAcc = nms.map({ $0.accolades }).min(),
              let maxAcc = nms.map({ $0.accolades }).max() else {
            return "Unknown"
        }
        return minAcc == maxAcc ? "\(minAcc)" : "\(minAcc)-\(maxAcc)"
    }
}
