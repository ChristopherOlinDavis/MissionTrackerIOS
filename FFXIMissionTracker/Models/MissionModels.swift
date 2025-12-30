//
//  MissionModels.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import Foundation

// MARK: - Location
struct Location: Codable, Hashable {
    let coordinates: String?
    let zone: String?
    let npc: String?
}

// MARK: - Mission Node
struct MissionNode: Codable, Identifiable, Hashable {
    let id: String
    let orderIndex: Int
    let title: String
    let description: String
    let dependencies: [String]
    let location: Location?

    func canStart(completedNodeIds: Set<String>) -> Bool {
        dependencies.allSatisfy { completedNodeIds.contains($0) }
    }
}

// MARK: - Gate Types
enum GateType: String, Codable {
    case missionSet = "missionSet"
    case mission = "mission"
    case node = "node"
    case level = "level"
    case item = "item"
    case other = "other"
}

// MARK: - Gate
struct Gate: Codable, Identifiable, Hashable {
    let id: String
    let type: GateType
    let afterNodeId: String?
    let requirement: String
    let description: String
}

// MARK: - Mission Image
struct MissionImage: Codable, Hashable {
    let src: String
    let alt: String
}

// MARK: - Reward
struct Reward: Codable, Hashable {
    let name: String
    let type: String? // "item", "gil", "exp", "keyitem", etc.
}

// MARK: - Mission
struct Mission: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let number: String?
    let url: String?
    let nodes: [MissionNode]
    let gates: [Gate]
    let htmlFile: String?
    let images: [MissionImage]?
    let nation: String?
    let rewards: [Reward]?

    var zones: [String] {
        let uniqueZones = Set(nodes.compactMap { $0.location?.zone })
        return Array(uniqueZones).sorted()
    }

    func missions(inZone zone: String) -> [Mission] {
        return zones.contains(zone) ? [self] : []
    }

    func dependentNodes(of nodeId: String) -> [MissionNode] {
        return nodes.filter { $0.dependencies.contains(nodeId) }
    }
}

// MARK: - Mission Set
struct MissionSet: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let source: String?
    let sourceUrl: String
    let lastScraped: String
    let lastKnownUpdate: String
    let totalMissions: Int?
    let missions: [Mission]

    func missions(inZone zone: String) -> [Mission] {
        return missions.filter { $0.zones.contains(zone) }
    }
}

// MARK: - API Response (for loading all mission sets at once)
struct MissionAPIResponse: Codable {
    let missionSets: [MissionSet]
    let stats: Stats

    struct Stats: Codable {
        let totalMissionSets: Int
        let totalMissions: Int
        let totalNodes: Int
    }
}
