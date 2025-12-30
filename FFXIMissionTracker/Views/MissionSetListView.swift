//
//  MissionSetListView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import SwiftUI

struct MissionSetListView: View {
    let missionSets: [MissionSet]
    @Bindable var progressTracker: MissionProgressTracker

    var body: some View {
        List(missionSets) { missionSet in
            NavigationLink(destination: MissionListView(
                missionSet: missionSet,
                progressTracker: progressTracker
            )) {
                MissionSetRowView(
                    missionSet: missionSet,
                    progressTracker: progressTracker
                )
            }
        }
        .navigationTitle("FFXI Missions")
    }
}

struct MissionSetRowView: View {
    let missionSet: MissionSet
    let progressTracker: MissionProgressTracker

    private var completedMissions: Int {
        missionSet.missions.filter { progressTracker.isMissionCompleted($0) }.count
    }

    private var totalMissions: Int {
        missionSet.missions.count
    }

    private var completionPercentage: Double {
        totalMissions > 0 ? Double(completedMissions) / Double(totalMissions) : 0
    }

    private var setRequirements: [Gate] {
        // Get gates from first mission that are expansion/set-level requirements
        guard let firstMission = missionSet.missions.first else { return [] }
        return firstMission.gates.filter { gate in
            gate.type == .other && (
                gate.requirement.lowercased().contains("expansion") ||
                gate.requirement.lowercased().contains("rank")
            )
        }
    }

    private var isNationMission: Bool {
        missionSet.category == "nation"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(missionSet.name)
                .font(.headline)

            // Show nation mission indicator
            if isNationMission {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("Only one nation required")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }

            // Show set-level requirements if any
            if !setRequirements.isEmpty {
                ForEach(setRequirements) { gate in
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text(gate.requirement)
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }

            HStack {
                Label("\(totalMissions) missions", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(completedMissions)/\(totalMissions)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: completionPercentage)
                .tint(.blue)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MissionSetListView(
            missionSets: [],
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
