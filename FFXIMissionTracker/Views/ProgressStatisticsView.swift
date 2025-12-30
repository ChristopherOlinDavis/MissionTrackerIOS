//
//  ProgressStatisticsView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/30/25.
//

import SwiftUI
import Charts

struct ProgressStatisticsView: View {
    @Bindable var characterManager: CharacterManager
    @Binding var progressTracker: MissionProgressTracker
    let missionSets: [MissionSet]
    let questSets: [MissionSet]

    private var selectedCharacter: Character? {
        characterManager.activeCharacter
    }

    private var totalMissions: Int {
        missionSets.reduce(0) { $0 + $1.missions.count }
    }

    private var totalQuests: Int {
        questSets.reduce(0) { $0 + $1.missions.count }
    }

    private var completedMissions: Int {
        missionSets.reduce(0) { sum, set in
            sum + set.missions.filter { progressTracker.isMissionCompleted($0) }.count
        }
    }

    private var completedQuests: Int {
        questSets.reduce(0) { sum, set in
            sum + set.missions.filter { progressTracker.isMissionCompleted($0) }.count
        }
    }

    private var totalNodes: Int {
        (missionSets + questSets).reduce(0) { sum, set in
            sum + set.missions.reduce(0) { $0 + $1.nodes.count }
        }
    }

    private var completedNodes: Int {
        progressTracker.completedNodes.count
    }

    private var overallCompletionPercentage: Double {
        let total = totalMissions + totalQuests
        let completed = completedMissions + completedQuests
        return total > 0 ? Double(completed) / Double(total) * 100 : 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Character Header
                    if let character = selectedCharacter {
                        VStack(spacing: 8) {
                            Text(character.displayName)
                                .font(.title2)
                                .bold()

                            Text("\(Int(overallCompletionPercentage))% Complete")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Overall Progress Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Overall Progress")
                            .font(.headline)
                            .padding(.horizontal)

                        if #available(iOS 16.0, macOS 13.0, *) {
                            Chart {
                                BarMark(
                                    x: .value("Category", "Missions"),
                                    y: .value("Count", completedMissions)
                                )
                                .foregroundStyle(.blue)

                                BarMark(
                                    x: .value("Category", "Missions"),
                                    y: .value("Count", totalMissions - completedMissions)
                                )
                                .foregroundStyle(.gray.opacity(0.3))

                                BarMark(
                                    x: .value("Category", "Quests"),
                                    y: .value("Count", completedQuests)
                                )
                                .foregroundStyle(.green)

                                BarMark(
                                    x: .value("Category", "Quests"),
                                    y: .value("Count", totalQuests - completedQuests)
                                )
                                .foregroundStyle(.gray.opacity(0.3))
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                        }
                    }

                    // Statistics Grid
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Missions",
                                value: "\(completedMissions)/\(totalMissions)",
                                icon: "list.bullet",
                                color: .blue
                            )

                            StatCard(
                                title: "Quests",
                                value: "\(completedQuests)/\(totalQuests)",
                                icon: "book",
                                color: .green
                            )
                        }

                        HStack(spacing: 16) {
                            StatCard(
                                title: "Objectives",
                                value: "\(completedNodes)/\(totalNodes)",
                                icon: "checkmark.circle",
                                color: .orange
                            )

                            StatCard(
                                title: "Completion",
                                value: String(format: "%.1f%%", overallCompletionPercentage),
                                icon: "chart.bar.fill",
                                color: .purple
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Mission Set Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mission Sets")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(missionSets) { set in
                            SetProgressRow(
                                set: set,
                                progressTracker: progressTracker,
                                color: .blue
                            )
                        }
                    }

                    // Quest Set Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quest Sets")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(questSets) { set in
                            SetProgressRow(
                                set: set,
                                progressTracker: progressTracker,
                                color: .green
                            )
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Progress Statistics")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SetProgressRow: View {
    let set: MissionSet
    let progressTracker: MissionProgressTracker
    let color: Color

    private var completedCount: Int {
        get {
            set.missions.filter { progressTracker.isMissionCompleted($0) }.count
        }
    }

    private var totalCount: Int {
        get {
            set.missions.count
        }
    }

    private var percentage: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(set.name)
                    .font(.subheadline)
                    .lineLimit(1)

                Spacer()

                Text("\(completedCount)/\(totalCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: percentage)
                .tint(color)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    ProgressStatisticsView(
        characterManager: CharacterManager(),
        progressTracker: .constant(MissionProgressTracker(characterManager: CharacterManager())),
        missionSets: [],
        questSets: []
    )
}
