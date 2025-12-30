//
//  MissionDataLoader.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import Foundation

enum MissionDataError: Error {
    case fileNotFound
    case invalidData
    case decodingFailed(Error)
}

class MissionDataLoader {
    static let shared = MissionDataLoader()

    private init() {}

    func loadMissionSet(filename: String) throws -> MissionSet {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw MissionDataError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(MissionSet.self, from: data)
        } catch let error as DecodingError {
            throw MissionDataError.decodingFailed(error)
        } catch {
            throw MissionDataError.invalidData
        }
    }

    func loadAllMissionSets() throws -> [MissionSet] {
        let filenames = [
            // Nation Missions
            "ffxiclopedia-bastok",
            "ffxiclopedia-sandoria",
            "ffxiclopedia-windurst",

            // Expansion Missions (in chronological order)
            "ffxiclopedia-zilart",
            "ffxiclopedia-promathia",
            "ffxiclopedia-aht-urhgan",
            "ffxiclopedia-wings-goddess",
            "ffxiclopedia-seekers-adoulin",
            "ffxiclopedia-rhapsodies",
            "ffxiclopedia-voracious-resurgence",

            // Other Mission Types
            "ffxiclopedia-campaign",
            "ffxiclopedia-coalition"
        ]

        return try filenames.compactMap { filename in
            try? loadMissionSet(filename: filename)
        }
    }

    func loadAllQuestSets() throws -> [MissionSet] {
        let filenames = [
            // Nation Quests
            "ffxiclopedia-bastok-quests",
            "ffxiclopedia-sandoria-quests",
            "ffxiclopedia-windurst-quests",
            "ffxiclopedia-jeuno-quests",

            // Expansion Quests
            "ffxiclopedia-aht-urhgan-quests",
            "ffxiclopedia-abyssea-quests",
            "ffxiclopedia-adoulin-quests",
            "ffxiclopedia-crystal-war-quests",
            "ffxiclopedia-wings-goddess-quests",

            // Other Quest Types
            "ffxiclopedia-outlands-quests"
        ]

        return try filenames.compactMap { filename in
            try? loadMissionSet(filename: filename)
        }
    }

    func loadAPIResponse() throws -> MissionAPIResponse {
        guard let url = Bundle.main.url(forResource: "api-response", withExtension: "json") else {
            throw MissionDataError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(MissionAPIResponse.self, from: data)
        } catch let error as DecodingError {
            throw MissionDataError.decodingFailed(error)
        } catch {
            throw MissionDataError.invalidData
        }
    }
}
