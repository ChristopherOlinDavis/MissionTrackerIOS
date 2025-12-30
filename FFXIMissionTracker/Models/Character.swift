//
//  Character.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/30/25.
//

import Foundation

struct Character: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var server: String
    var job: String?
    var createdDate: Date
    var completedNodeIds: Set<String>

    init(id: UUID = UUID(), name: String, server: String, job: String? = nil, createdDate: Date = Date(), completedNodeIds: Set<String> = []) {
        self.id = id
        self.name = name
        self.server = server
        self.job = job
        self.createdDate = createdDate
        self.completedNodeIds = completedNodeIds
    }

    var displayName: String {
        if let job = job, !job.isEmpty {
            return "\(name) (\(job))"
        }
        return name
    }

    var completionStats: (missions: Int, quests: Int, total: Int) {
        // This is a simple count - could be enhanced later
        let total = completedNodeIds.count
        return (missions: total, quests: 0, total: total)
    }
}
