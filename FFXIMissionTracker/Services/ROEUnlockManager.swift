//
//  ROEUnlockManager.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import Foundation

class ROEUnlockManager {
    // Singleton for shared access
    static let shared = ROEUnlockManager()

    private init() {}

    // Database of unlock requirements for categories and subcategories
    private let unlockRequirements: [String: ROEUnlockRequirement] = [
        // Tutorial - Always available
        "Tutorial": .none,
        "Tutorial|Basics": .none,
        "Tutorial|Intermediate": .none,
        "Tutorial|Synthesis": .none,
        "Tutorial|Quests 1": .none,
        "Tutorial|Quests (Artifact 1)": .none,
        "Tutorial|Quests (Artifact 2)": .none,
        "Tutorial|Quests (Artifact 3)": .none,
        "Tutorial|Level Cap Increase": .none,
        "Tutorial|Storage Expansion": .none,
        "Tutorial|Quests (Weapon Skills)": .none,
        "Tutorial|Missions (Rhapsodies of Vana'diel)": .none,
        "Tutorial|Missions (San d'Oria)": .none,
        "Tutorial|Missions (Bastok)": .none,
        "Tutorial|Missions (Windurst)": .none,
        "Tutorial|Missions (Zilart)": .none,
        "Tutorial|Missions (Promathia)": .none,
        "Tutorial|Missions (Aht Urhgan)": .none,
        "Tutorial|Missions (Altana)": .none,
        "Tutorial|Missions (Adoulin)": .none,

        // Combat - Always available
        "Combat (Wide Area)": .none,
        "Combat (Region)": .none,

        // Fishing - Always available
        "Fishing": .none,

        // Crafting - Always available
        "Crafting": .none,

        // Harvesting - Always available
        "Harvesting": .none,

        // Content - Always available
        "Content": .none,

        // Achievements - Always available
        "Achievements": .none,

        // Unity - Always available
        "Unity": .none,

        // Vana'versary - Requires First Step Forward
        "Vana'versary": .firstStepForward,
        "Vana'versary|15th Vana'versary I": .firstStepForward,
        "Vana'versary|15th Vana'versary II": .firstStepForward,
        "Vana'versary|15th Vana'versary III": .firstStepForward,
        "Vana'versary|15th Vana'versary IV": .firstStepForward,
        "Vana'versary|15th Vana'versary V": .firstStepForward,
        "Vana'versary|17th Vana'versary": .firstStepForward,

        // Special Events - Vana'bout requires Ambuscade
        "Special Events": .none,
        "Special Events|Vana'bout Daily": .ambuscade,
        "Special Events|Vana'bout Round": .ambuscade,

        // Other - RoE Quests unlock progressively
        "Other": .none,
        "Other|RoE Quests": .objectiveCount(50),
        "Other|RoE Quests 2": .objectiveCount(100),
        "Other|RoE Quests 3": .multiple([
            .objectiveCount(150),
            .mission("Rise of Zilart: Awakening"),
            .mission("Chains of Promathia: Dawn"),
            .quest("Bundle of half-inscribed scrolls")
        ]),
        "Other|RoE Quests 4": .mission("The Voracious Resurgence Mission 4-4"),
        "Other|Daily Objectives": .none,
        "Other|Monthly Objectives": .none,

        // Objective List - Limited time challenges
        "Objective List": .none,
        "Objective List|Limited-time Challenges": .none,
    ]

    // Get unlock requirement for a category
    func getUnlockRequirement(for categoryName: String) -> ROEUnlockRequirement {
        return unlockRequirements[categoryName] ?? .none
    }

    // Get unlock requirement for a subcategory
    func getUnlockRequirement(for categoryName: String, subcategory: String) -> ROEUnlockRequirement {
        let key = "\(categoryName)|\(subcategory)"
        return unlockRequirements[key] ?? unlockRequirements[categoryName] ?? .none
    }

    // Check if a category/subcategory is unlocked based on progress
    func isUnlocked(categoryName: String, subcategory: String? = nil, completedObjectiveCount: Int) -> Bool {
        let requirement = subcategory != nil
            ? getUnlockRequirement(for: categoryName, subcategory: subcategory!)
            : getUnlockRequirement(for: categoryName)

        return isRequirementMet(requirement, completedObjectiveCount: completedObjectiveCount)
    }

    private func isRequirementMet(_ requirement: ROEUnlockRequirement, completedObjectiveCount: Int) -> Bool {
        switch requirement {
        case .none:
            return true
        case .firstStepForward:
            // TODO: Could check if "First Step Forward" objective is completed
            return true // For now, assume always available
        case .objectiveCount(let count):
            return completedObjectiveCount >= count
        case .quest, .mission:
            // TODO: Could check specific quest/mission completion
            return true // For now, assume available
        case .ambuscade:
            // TODO: Could check if "Stepping into an Ambuscade" is completed
            return true // For now, assume available
        case .multiple(let reqs):
            return reqs.allSatisfy { isRequirementMet($0, completedObjectiveCount: completedObjectiveCount) }
        }
    }

    // Get human-readable unlock info
    func getUnlockInfo(for categoryName: String, subcategory: String? = nil) -> String? {
        let requirement = subcategory != nil
            ? getUnlockRequirement(for: categoryName, subcategory: subcategory!)
            : getUnlockRequirement(for: categoryName)

        guard case .none = requirement else {
            return requirement.displayText
        }
        return nil
    }

    // Get special notes about unlock requirements
    func getNotes(for categoryName: String, subcategory: String? = nil) -> String? {
        let key = subcategory != nil ? "\(categoryName)|\(subcategory!)" : categoryName

        switch key {
        case "Other|RoE Quests":
            return "Speak to Nantoto in Lower Jeuno after completing 50 objectives"
        case "Other|RoE Quests 2":
            return "Additional objectives unlock at 100, 150, 200+ completed"
        case "Other|RoE Quests 3":
            return "Requires 11+ Trusts from nation cities and specific key items from Jamal"
        case "Other|RoE Quests 4":
            return "Speak to Elijah in Upper Jeuno. More unlock with VR mission progress"
        case "Special Events|Vana'bout Daily", "Special Events|Vana'bout Round":
            return "Found in Tutorial > Basics section"
        default:
            return nil
        }
    }
}
