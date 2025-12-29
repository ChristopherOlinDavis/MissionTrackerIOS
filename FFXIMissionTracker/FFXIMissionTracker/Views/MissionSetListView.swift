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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(missionSet.name)
                .font(.headline)

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
            progressTracker: MissionProgressTracker()
        )
    }
}
