//
//  Character.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/30/25.
//

import Foundation

/// Progress data structure for tracking different types of content
struct ProgressData: Codable, Hashable {
    var completedNodeIds: Set<String>
    var completedMissionIds: Set<String>
    var completedQuestIds: Set<String>
    var completedUnityNMIds: Set<String>
    var completedROEIds: Set<String>

    // Metadata for statistics
    var lastUpdated: Date
    var totalPlaytime: TimeInterval // In seconds

    init(
        completedNodeIds: Set<String> = [],
        completedMissionIds: Set<String> = [],
        completedQuestIds: Set<String> = [],
        completedUnityNMIds: Set<String> = [],
        completedROEIds: Set<String> = [],
        lastUpdated: Date = Date(),
        totalPlaytime: TimeInterval = 0
    ) {
        self.completedNodeIds = completedNodeIds
        self.completedMissionIds = completedMissionIds
        self.completedQuestIds = completedQuestIds
        self.completedUnityNMIds = completedUnityNMIds
        self.completedROEIds = completedROEIds
        self.lastUpdated = lastUpdated
        self.totalPlaytime = totalPlaytime
    }
}

struct Character: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var server: String
    var job: String?
    var createdDate: Date

    // Enhanced progress tracking
    var progress: ProgressData

    // Legacy support - computed property for backward compatibility
    var completedNodeIds: Set<String> {
        get { progress.completedNodeIds }
        set { progress.completedNodeIds = newValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        server: String,
        job: String? = nil,
        createdDate: Date = Date(),
        completedNodeIds: Set<String> = [],
        progress: ProgressData? = nil
    ) {
        self.id = id
        self.name = name
        self.server = server
        self.job = job
        self.createdDate = createdDate

        // If progress is provided, use it; otherwise create from legacy data
        if let progress = progress {
            self.progress = progress
        } else {
            self.progress = ProgressData(completedNodeIds: completedNodeIds)
        }
    }

    var displayName: String {
        if let job = job, !job.isEmpty {
            return "\(name) (\(job))"
        }
        return name
    }

    var completionStats: (missions: Int, quests: Int, unityNMs: Int, roe: Int, total: Int) {
        let missions = progress.completedMissionIds.count
        let quests = progress.completedQuestIds.count
        let unityNMs = progress.completedUnityNMIds.count
        let roe = progress.completedROEIds.count
        let total = progress.completedNodeIds.count

        return (missions: missions, quests: quests, unityNMs: unityNMs, roe: roe, total: total)
    }

    var formattedPlaytime: String {
        let hours = Int(progress.totalPlaytime / 3600)
        let minutes = Int((progress.totalPlaytime.truncatingRemainder(dividingBy: 3600)) / 60)

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
