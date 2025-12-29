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
    private(set) var completedNodes: Set<String> = []

    private let userDefaultsKey = "completedMissionNodes"

    init() {
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

    private func saveProgress() {
        UserDefaults.standard.set(Array(completedNodes), forKey: userDefaultsKey)
    }

    private func loadProgress() {
        if let saved = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            completedNodes = Set(saved)
        }
    }
}
