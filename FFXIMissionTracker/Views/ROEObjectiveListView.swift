//
//  ROEObjectiveListView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import SwiftUI

struct ROEObjectiveListView: View {
    let subcategory: ROESubcategoryGroup
    @Bindable var progressTracker: MissionProgressTracker

    @State private var showCompletedOnly = false
    @State private var showIncompleteOnly = false

    private var filteredObjectives: [ROEObjective] {
        var objectives = subcategory.objectives

        if showCompletedOnly {
            objectives = objectives.filter { progressTracker.isItemCompleted($0.id, category: .roe) }
        } else if showIncompleteOnly {
            objectives = objectives.filter { !progressTracker.isItemCompleted($0.id, category: .roe) }
        }

        return objectives
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter chips
            HStack(spacing: 12) {
                FilterChip(
                    title: "Completed",
                    isSelected: showCompletedOnly,
                    icon: "checkmark.circle.fill",
                    color: .green
                ) {
                    if showCompletedOnly {
                        showCompletedOnly = false
                    } else {
                        showCompletedOnly = true
                        showIncompleteOnly = false
                    }
                }

                FilterChip(
                    title: "Incomplete",
                    isSelected: showIncompleteOnly,
                    icon: "circle",
                    color: .orange
                ) {
                    if showIncompleteOnly {
                        showIncompleteOnly = false
                    } else {
                        showIncompleteOnly = true
                        showCompletedOnly = false
                    }
                }

                Spacer()
            }
            .padding()

            Divider()

            if filteredObjectives.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "trophy")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)

                    Text("No objectives")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text("Try adjusting your filters")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredObjectives) { objective in
                        NavigationLink {
                            ROEObjectiveDetailView(
                                objective: objective,
                                progressTracker: progressTracker
                            )
                        } label: {
                            ROEObjectiveRow(
                                objective: objective,
                                isCompleted: progressTracker.isItemCompleted(objective.id, category: .roe)
                            )
                        }
                    }
                }
                #if os(iOS)
                .listStyle(.insetGrouped)
                #endif
            }
        }
        .navigationTitle(subcategory.displayName)
    }
}

#Preview {
    NavigationStack {
        ROEObjectiveListView(
            subcategory: ROESubcategoryGroup(
                name: "Test Subcategory",
                categoryName: "Test Category",
                objectives: []
            ),
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
