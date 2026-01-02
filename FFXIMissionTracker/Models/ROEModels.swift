//
//  ROEModels.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import Foundation

// MARK: - ROE Unlock Requirements
enum ROEUnlockRequirement: Codable, Hashable {
    case none // Always available
    case firstStepForward // Complete "First Step Forward" tutorial
    case objectiveCount(Int) // Complete N unique objectives
    case quest(String) // Complete specific quest
    case mission(String) // Complete specific mission
    case ambuscade // Complete "Stepping into an Ambuscade"
    case multiple([ROEUnlockRequirement]) // Multiple requirements (AND)

    var displayText: String {
        switch self {
        case .none:
            return "Available from start"
        case .firstStepForward:
            return "Complete 'First Step Forward' tutorial"
        case .objectiveCount(let count):
            return "Complete \(count) unique objectives"
        case .quest(let name):
            return "Complete quest: \(name)"
        case .mission(let name):
            return "Complete mission: \(name)"
        case .ambuscade:
            return "Complete 'Stepping into an Ambuscade'"
        case .multiple(let reqs):
            return reqs.map { $0.displayText }.joined(separator: " AND ")
        }
    }

    var icon: String {
        switch self {
        case .none:
            return "checkmark.circle.fill"
        case .firstStepForward:
            return "graduationcap.fill"
        case .objectiveCount:
            return "number.circle.fill"
        case .quest:
            return "book.fill"
        case .mission:
            return "flag.fill"
        case .ambuscade:
            return "flame.fill"
        case .multiple:
            return "checklist"
        }
    }
}

struct ROECategoryUnlockInfo: Codable, Hashable {
    let categoryName: String
    let subcategoryName: String?
    let requirement: ROEUnlockRequirement
    let notes: String?
}

// MARK: - ROE Reward Item
struct ROERewardItem: Codable, Hashable {
    let name: String
}

// MARK: - ROE NPC
struct ROENPC: Codable, Hashable {
    let name: String
    let url: String?
}

// MARK: - ROE Rewards
struct ROERewards: Codable, Hashable {
    let sparks: Int?
    let exp: Int?
    let accolades: Int?
    let items: [ROERewardItem]?
}

// MARK: - ROE Objective
struct ROEObjective: Codable, Identifiable, Hashable {
    let name: String
    let category: String
    let subcategory: String
    let description: String
    let objectiveCount: Int?
    let repeatable: Bool
    let rewards: ROERewards?
    let npcs: [ROENPC]?

    // Computed ID from name + category + subcategory
    var id: String {
        "\(category)|\(subcategory)|\(name)"
    }

    var displayName: String {
        name
    }

    var hasRewards: Bool {
        if let rewards = rewards {
            return rewards.sparks != nil ||
                   rewards.exp != nil ||
                   rewards.accolades != nil ||
                   !(rewards.items?.isEmpty ?? true)
        }
        return false
    }
}

// MARK: - ROE Category Info
struct ROECategoryInfo: Codable, Hashable {
    let name: String
    let subcategories: [String]
}

// MARK: - ROE Stats Category
struct ROEStatsCategory: Codable, Hashable {
    let name: String
    let count: Int
}

// MARK: - ROE Stats
struct ROEStats: Codable, Hashable {
    let totalObjectives: Int
    let totalCategories: Int
    let byCategory: [ROEStatsCategory]
}

// MARK: - ROE Response
struct ROEResponse: Codable {
    let version: String
    let source: String
    let sourceUrl: String
    let lastUpdated: String
    let categories: [ROECategoryInfo]
    let objectives: [ROEObjective]
    let stats: ROEStats
}

// MARK: - Grouped ROE Data (for UI)
struct ROECategoryGroup: Identifiable, Hashable {
    let name: String
    let subcategories: [ROESubcategoryGroup]

    var id: String { name }

    var totalObjectives: Int {
        subcategories.reduce(0) { $0 + $1.objectives.count }
    }
}

struct ROESubcategoryGroup: Identifiable, Hashable {
    let name: String
    let categoryName: String
    let objectives: [ROEObjective]

    var id: String { "\(categoryName)|\(name)" }

    var displayName: String {
        name
    }
}
