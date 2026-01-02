//
//  MissionListView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import SwiftUI

struct MissionListView: View {
    let missionSet: MissionSet
    @Bindable var progressTracker: MissionProgressTracker

    private var hasNationMissions: Bool {
        missionSet.missions.contains { $0.nation != nil }
    }

    private var groupedByNation: [String: [Mission]] {
        Dictionary(grouping: missionSet.missions.filter { $0.nation != nil }, by: { $0.nation ?? "Other" })
    }

    private var otherMissions: [Mission] {
        missionSet.missions.filter { $0.nation == nil }
    }

    private var sortedNations: [String] {
        Array(groupedByNation.keys).sorted()
    }

    var body: some View {
        List {
            if hasNationMissions {
                // Group by nation for nation-based quests/missions
                ForEach(sortedNations, id: \.self) { nation in
                    Section(header: Text(nation.capitalized)) {
                        ForEach(groupedByNation[nation] ?? []) { mission in
                            NavigationLink(destination: MissionDetailView(
                                mission: mission,
                                progressTracker: progressTracker
                            )) {
                                MissionRowView(
                                    mission: mission,
                                    progressTracker: progressTracker
                                )
                            }
                        }
                    }
                }

                // Other missions without nation
                if !otherMissions.isEmpty {
                    Section(header: Text("Other")) {
                        ForEach(otherMissions) { mission in
                            NavigationLink(destination: MissionDetailView(
                                mission: mission,
                                progressTracker: progressTracker
                            )) {
                                MissionRowView(
                                    mission: mission,
                                    progressTracker: progressTracker
                                )
                            }
                        }
                    }
                }
            } else {
                // No nation grouping needed
                ForEach(missionSet.missions) { mission in
                    NavigationLink(destination: MissionDetailView(
                        mission: mission,
                        progressTracker: progressTracker
                    )) {
                        MissionRowView(
                            mission: mission,
                            progressTracker: progressTracker
                        )
                    }
                }
            }
        }
        .navigationTitle(missionSet.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct MissionRowView: View {
    let mission: Mission
    let progressTracker: MissionProgressTracker

    private var progress: Double {
        progressTracker.missionProgress(mission)
    }

    private var isCompleted: Bool {
        progressTracker.isMissionCompleted(mission)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let number = mission.number {
                    Text(number)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isCompleted ? Color.green : Color.blue)
                        .cornerRadius(6)
                }

                Text(mission.title)
                    .font(.headline)
                    .strikethrough(isCompleted, color: .secondary)

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            HStack {
                Label("\(mission.nodes.count) steps", systemImage: "list.number")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !mission.zones.isEmpty {
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    Label(mission.zones.first ?? "", systemImage: "map")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !mission.gates.isEmpty {
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    Label("\(mission.gates.count)", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: progress)
                .tint(isCompleted ? .green : .blue)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MissionListView(
            missionSet: MissionSet(
                id: "test",
                name: "Test Missions",
                category: "test",
                source: "test",
                sourceUrl: "https://test.com",
                lastScraped: "",
                lastKnownUpdate: "",
                totalMissions: 0,
                missions: []
            ),
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
