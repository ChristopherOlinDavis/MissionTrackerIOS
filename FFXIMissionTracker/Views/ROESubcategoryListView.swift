//
//  ROESubcategoryListView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import SwiftUI

struct ROESubcategoryListView: View {
    let category: ROECategoryGroup
    @Bindable var progressTracker: MissionProgressTracker

    var body: some View {
        List {
            ForEach(category.subcategories) { subcategory in
                NavigationLink(destination: ROEObjectiveListView(
                    subcategory: subcategory,
                    progressTracker: progressTracker
                )) {
                    ROESubcategoryRow(
                        subcategory: subcategory,
                        progressTracker: progressTracker
                    )
                }
            }
        }
        .navigationTitle(category.name)
    }
}

struct ROESubcategoryRow: View {
    let subcategory: ROESubcategoryGroup
    let progressTracker: MissionProgressTracker

    private var completedObjectives: Int {
        subcategory.objectives.filter {
            progressTracker.isItemCompleted($0.id, category: .roe)
        }.count
    }

    private var totalObjectives: Int {
        subcategory.objectives.count
    }

    private var completionPercentage: Double {
        totalObjectives > 0 ? Double(completedObjectives) / Double(totalObjectives) : 0
    }

    private var unlockInfo: String? {
        ROEUnlockManager.shared.getUnlockInfo(for: subcategory.categoryName, subcategory: subcategory.name)
    }

    private var unlockNotes: String? {
        ROEUnlockManager.shared.getNotes(for: subcategory.categoryName, subcategory: subcategory.name)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(subcategory.displayName)
                .font(.headline)

            // Show unlock requirement if any
            if let unlockInfo = unlockInfo {
                HStack(spacing: 4) {
                    Image(systemName: ROEUnlockManager.shared.getUnlockRequirement(for: subcategory.categoryName, subcategory: subcategory.name).icon)
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text(unlockInfo)
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }

            // Show additional notes if any
            if let notes = unlockNotes {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text(notes)
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }

            HStack {
                Label("\(totalObjectives) objectives", systemImage: "trophy")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(completedObjectives)/\(totalObjectives)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: completionPercentage)
                .tint(.orange)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ROESubcategoryListView(
            category: ROECategoryGroup(name: "Test Category", subcategories: []),
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
