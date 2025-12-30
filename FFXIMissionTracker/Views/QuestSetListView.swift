//
//  QuestSetListView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import SwiftUI

struct QuestSetListView: View {
    let questSets: [MissionSet]
    @Bindable var progressTracker: MissionProgressTracker

    var body: some View {
        List(questSets) { questSet in
            NavigationLink(destination: MissionListView(
                missionSet: questSet,
                progressTracker: progressTracker
            )) {
                QuestSetRowView(
                    questSet: questSet,
                    progressTracker: progressTracker
                )
            }
        }
        .navigationTitle("FFXI Quests")
    }
}

struct QuestSetRowView: View {
    let questSet: MissionSet
    let progressTracker: MissionProgressTracker

    private var completedQuests: Int {
        questSet.missions.filter { progressTracker.isMissionCompleted($0) }.count
    }

    private var totalQuests: Int {
        questSet.missions.count
    }

    private var completionPercentage: Double {
        totalQuests > 0 ? Double(completedQuests) / Double(totalQuests) : 0
    }

    private var isNationQuest: Bool {
        questSet.category == "nation"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(questSet.name)
                .font(.headline)

            // Show nation quest indicator
            if isNationQuest {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text("Optional - enhance your chosen nation")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }

            HStack {
                Label("\(totalQuests) quests", systemImage: "book")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(completedQuests)/\(totalQuests)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: completionPercentage)
                .tint(.green)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        QuestSetListView(
            questSets: [],
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
