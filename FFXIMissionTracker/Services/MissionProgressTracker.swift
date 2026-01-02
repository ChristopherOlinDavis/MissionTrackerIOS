//
//  MissionProgressTracker.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import Foundation
import SwiftUI

/// Category of trackable content
enum ProgressCategory: String, Codable, CaseIterable {
    case mission = "Mission"
    case quest = "Quest"
    case unityNM = "Unity NM"
    case roe = "ROE"

    var icon: String {
        switch self {
        case .mission: return "list.bullet.clipboard"
        case .quest: return "book"
        case .unityNM: return "flag.2.crossed"
        case .roe: return "trophy"
        }
    }

    var color: String {
        switch self {
        case .mission: return "blue"
        case .quest: return "green"
        case .unityNM: return "purple"
        case .roe: return "orange"
        }
    }
}

/// Statistics for a specific category
struct CategoryStats {
    let category: ProgressCategory
    let completed: Int
    let total: Int
    let percentage: Double

    init(category: ProgressCategory, completed: Int, total: Int) {
        self.category = category
        self.completed = completed
        self.total = total
        self.percentage = total > 0 ? Double(completed) / Double(total) * 100 : 0
    }
}

@Observable
class MissionProgressTracker {
    var characterManager: CharacterManager

    // Legacy node tracking (backward compatible)
    private(set) var completedNodes: Set<String> = []

    // Enhanced category-based tracking
    private(set) var completedMissions: Set<String> = []
    private(set) var completedQuests: Set<String> = []
    private(set) var completedUnityNMs: Set<String> = []
    private(set) var completedROEs: Set<String> = []

    init(characterManager: CharacterManager) {
        self.characterManager = characterManager
        loadProgress()
    }

    // MARK: - Node Operations (Legacy)

    func completeNode(_ nodeId: String) {
        completedNodes.insert(nodeId)
        updateLastModified()
        saveProgress()
    }

    func uncompleteNode(_ nodeId: String) {
        completedNodes.remove(nodeId)
        updateLastModified()
        saveProgress()
    }

    func toggleNode(_ nodeId: String) {
        if completedNodes.contains(nodeId) {
            uncompleteNode(nodeId)
        } else {
            completeNode(nodeId)
        }
    }

    func isCompleted(_ nodeId: String) -> Bool {
        completedNodes.contains(nodeId)
    }

    // MARK: - Mission/Quest Operations

    func completeMission(_ missionId: String) {
        completedMissions.insert(missionId)
        updateLastModified()
        saveProgress()
    }

    func uncompleteMission(_ missionId: String) {
        completedMissions.remove(missionId)
        updateLastModified()
        saveProgress()
    }

    func toggleMission(_ missionId: String) {
        if completedMissions.contains(missionId) {
            uncompleteMission(missionId)
        } else {
            completeMission(missionId)
        }
    }

    func isMissionCompleted(_ mission: Mission) -> Bool {
        // Check if all nodes are completed
        mission.nodes.allSatisfy { completedNodes.contains($0.id) }
    }

    func missionProgress(_ mission: Mission) -> Double {
        let completed = mission.nodes.filter { completedNodes.contains($0.id) }.count
        return mission.nodes.isEmpty ? 0 : Double(completed) / Double(mission.nodes.count)
    }

    func availableNodes(in mission: Mission) -> [MissionNode] {
        mission.nodes.filter { node in
            !completedNodes.contains(node.id) && node.canStart(completedNodeIds: completedNodes)
        }
    }

    // MARK: - Category Operations

    func completeItem(_ itemId: String, category: ProgressCategory) {
        switch category {
        case .mission:
            completedMissions.insert(itemId)
        case .quest:
            completedQuests.insert(itemId)
        case .unityNM:
            completedUnityNMs.insert(itemId)
        case .roe:
            completedROEs.insert(itemId)
        }
        updateLastModified()
        saveProgress()
    }

    func uncompleteItem(_ itemId: String, category: ProgressCategory) {
        switch category {
        case .mission:
            completedMissions.remove(itemId)
        case .quest:
            completedQuests.remove(itemId)
        case .unityNM:
            completedUnityNMs.remove(itemId)
        case .roe:
            completedROEs.remove(itemId)
        }
        updateLastModified()
        saveProgress()
    }

    func isItemCompleted(_ itemId: String, category: ProgressCategory) -> Bool {
        switch category {
        case .mission:
            return completedMissions.contains(itemId)
        case .quest:
            return completedQuests.contains(itemId)
        case .unityNM:
            return completedUnityNMs.contains(itemId)
        case .roe:
            return completedROEs.contains(itemId)
        }
    }

    // MARK: - Statistics

    func categoryStats(for category: ProgressCategory, total: Int) -> CategoryStats {
        let completed: Int
        switch category {
        case .mission:
            completed = completedMissions.count
        case .quest:
            completed = completedQuests.count
        case .unityNM:
            completed = completedUnityNMs.count
        case .roe:
            completed = completedROEs.count
        }
        return CategoryStats(category: category, completed: completed, total: total)
    }

    func overallStats(missionTotal: Int = 0, questTotal: Int = 0, unityNMTotal: Int = 0, roeTotal: Int = 0) -> [CategoryStats] {
        return [
            categoryStats(for: .mission, total: missionTotal),
            categoryStats(for: .quest, total: questTotal),
            categoryStats(for: .unityNM, total: unityNMTotal),
            categoryStats(for: .roe, total: roeTotal)
        ]
    }

    var totalObjectivesCompleted: Int {
        completedNodes.count
    }

    var lastUpdated: Date {
        guard let character = characterManager.activeCharacter else {
            return Date()
        }
        return character.progress.lastUpdated
    }

    // MARK: - Progress Management

    func resetProgress() {
        completedNodes.removeAll()
        completedMissions.removeAll()
        completedQuests.removeAll()
        completedUnityNMs.removeAll()
        completedROEs.removeAll()
        saveProgress()
    }

    func resetCategory(_ category: ProgressCategory) {
        switch category {
        case .mission:
            completedMissions.removeAll()
        case .quest:
            completedQuests.removeAll()
        case .unityNM:
            completedUnityNMs.removeAll()
        case .roe:
            completedROEs.removeAll()
        }
        updateLastModified()
        saveProgress()
    }

    func refreshProgress() {
        loadProgress()
    }

    // MARK: - Persistence

    private func updateLastModified() {
        // This will be saved during saveProgress()
    }

    private func saveProgress() {
        guard let activeCharacterId = characterManager.activeCharacter?.id else { return }

        let progressData = ProgressData(
            completedNodeIds: completedNodes,
            completedMissionIds: completedMissions,
            completedQuestIds: completedQuests,
            completedUnityNMIds: completedUnityNMs,
            completedROEIds: completedROEs,
            lastUpdated: Date(),
            totalPlaytime: characterManager.activeCharacter?.progress.totalPlaytime ?? 0
        )

        characterManager.saveProgressData(progressData, for: activeCharacterId)
    }

    private func loadProgress() {
        guard let activeCharacterId = characterManager.activeCharacter?.id,
              let character = characterManager.characters.first(where: { $0.id == activeCharacterId }) else {
            completedNodes = []
            completedMissions = []
            completedQuests = []
            completedUnityNMs = []
            completedROEs = []
            return
        }

        let progress = character.progress
        completedNodes = progress.completedNodeIds
        completedMissions = progress.completedMissionIds
        completedQuests = progress.completedQuestIds
        completedUnityNMs = progress.completedUnityNMIds
        completedROEs = progress.completedROEIds
    }
}
