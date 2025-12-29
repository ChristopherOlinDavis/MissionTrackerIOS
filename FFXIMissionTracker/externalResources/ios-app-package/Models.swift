// FFXI Mission Models
// Generated from FFXI Mission Scraper data
// Compatible with Swift 5.0+

import Foundation

// MARK: - Root API Response
struct MissionAPIResponse: Codable {
    let version: String
    let generatedAt: String
    let missionSets: [MissionSet]
    let stats: APIStats
}

struct APIStats: Codable {
    let totalSets: Int
    let totalMissions: Int
    let totalNodes: Int
}

// MARK: - Mission Set
struct MissionSet: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let sourceUrl: String
    let lastScraped: String
    let missions: [Mission]

    var totalMissions: Int {
        missions.count
    }
}

// MARK: - Mission
struct Mission: Codable, Identifiable {
    let id: String
    let title: String
    let number: String?
    let nodes: [MissionNode]
    let gates: [MissionGate]
    let metadata: MissionMetadata?
}

// MARK: - Mission Node
struct MissionNode: Codable, Identifiable {
    let id: String
    let orderIndex: Int
    let title: String
    let description: String
    let dependencies: [String]
    let location: Location?

    var hasLocation: Bool {
        location != nil
    }
}

// MARK: - Location
struct Location: Codable {
    let coordinates: String?
    let zone: String?
    let npc: String?

    var displayText: String {
        var parts: [String] = []
        if let zone = zone {
            parts.append(zone)
        }
        if let coords = coordinates {
            parts.append("(\(coords))")
        }
        if let npc = npc {
            parts.append(npc)
        }
        return parts.joined(separator: " ")
    }
}

// MARK: - Mission Gate (for branching missions)
struct MissionGate: Codable, Identifiable {
    let id: String
    let type: String
    let title: String
    let description: String
    let choices: [GateChoice]
}

struct GateChoice: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let nextNodeId: String
}

// MARK: - Mission Metadata
struct MissionMetadata: Codable {
    let category: String?
    let missionSet: String?
    let minLevel: Int?
    let difficulty: String?
    let rewards: [String]?
}

// MARK: - Helper Extensions

extension MissionSet {
    /// Get missions filtered by number pattern (e.g., "1-1", "2-3")
    func missions(withNumberPrefix prefix: String) -> [Mission] {
        missions.filter { mission in
            guard let number = mission.number else { return false }
            return number.hasPrefix(prefix)
        }
    }

    /// Get all missions in a specific zone
    func missions(inZone zone: String) -> [Mission] {
        missions.filter { mission in
            mission.nodes.contains { node in
                node.location?.zone?.lowercased() == zone.lowercased()
            }
        }
    }
}

extension Mission {
    /// Get the starting node (first node with no dependencies)
    var startNode: MissionNode? {
        nodes.first { $0.dependencies.isEmpty }
    }

    /// Get all unique zones mentioned in this mission
    var zones: [String] {
        let allZones = nodes.compactMap { $0.location?.zone }
        return Array(Set(allZones)).sorted()
    }

    /// Get node by ID
    func node(withId id: String) -> MissionNode? {
        nodes.first { $0.id == id }
    }

    /// Get nodes that depend on a specific node
    func dependentNodes(of nodeId: String) -> [MissionNode] {
        nodes.filter { $0.dependencies.contains(nodeId) }
    }
}

extension MissionNode {
    /// Check if this node can be started (all dependencies met)
    func canStart(completedNodeIds: Set<String>) -> Bool {
        dependencies.allSatisfy { completedNodeIds.contains($0) }
    }
}

// MARK: - Example Usage

/*
// Loading the API response
let url = Bundle.main.url(forResource: "api-response", withExtension: "json")!
let data = try Data(contentsOf: url)
let decoder = JSONDecoder()
let apiResponse = try decoder.decode(MissionAPIResponse.self, from: data)

// Working with mission sets
let bastokMissions = apiResponse.missionSets.first { $0.id == "bastok-rank" }

// Finding a specific mission
let zeruhnReport = bastokMissions?.missions.first { $0.title == "The Zeruhn Report" }

// Checking node dependencies
let completedNodes: Set<String> = ["bastok-rank-the-zeruhn-report-node-1"]
let nextNodes = zeruhnReport?.nodes.filter { $0.canStart(completedNodeIds: completedNodes) }

// Filtering by location
let bastokMinesMissions = bastokMissions?.missions(inZone: "Bastok Mines")
*/
