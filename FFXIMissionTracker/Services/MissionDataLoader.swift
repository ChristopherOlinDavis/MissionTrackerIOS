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
            "ffxiclopedia-bastok",
            "ffxiclopedia-sandoria",
            "ffxiclopedia-windurst",
            "zilart",
            "promathia"
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
