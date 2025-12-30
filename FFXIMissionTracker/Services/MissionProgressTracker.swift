//
//  MissionProgressTracker.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import Foundation
import SwiftUI

@Observable
class MissionProgressTracker {
    var characterManager: CharacterManager
    private(set) var completedNodes: Set<String> = []

    init(characterManager: CharacterManager) {
        self.characterManager = characterManager
        loadProgress()
    }

    func completeNode(_ nodeId: String) {
        completedNodes.insert(nodeId)
        saveProgress()
    }

    func uncompleteNode(_ nodeId: String) {
        completedNodes.remove(nodeId)
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

    func isMissionCompleted(_ mission: Mission) -> Bool {
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

    func resetProgress() {
        completedNodes.removeAll()
        saveProgress()
    }

    func refreshProgress() {
        loadProgress()
    }

    private func saveProgress() {
        guard let activeCharacterId = characterManager.activeCharacter?.id else { return }
        characterManager.saveProgress(nodeIds: completedNodes, for: activeCharacterId)
    }

    private func loadProgress() {
        guard let activeCharacterId = characterManager.activeCharacter?.id else {
            completedNodes = []
            return
        }
        completedNodes = characterManager.getProgress(for: activeCharacterId)
    }
}
