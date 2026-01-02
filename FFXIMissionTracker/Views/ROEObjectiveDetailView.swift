//
//  ROEObjectiveDetailView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import SwiftUI

struct ROEObjectiveDetailView: View {
    let objective: ROEObjective
    @Bindable var progressTracker: MissionProgressTracker

    @State private var isCompleted: Bool

    init(objective: ROEObjective, progressTracker: MissionProgressTracker) {
        self.objective = objective
        self.progressTracker = progressTracker
        _isCompleted = State(initialValue: progressTracker.isItemCompleted(objective.id, category: .roe))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with completion button
                VStack(alignment: .leading, spacing: 16) {
                    Text(objective.name)
                        .font(.title)
                        .fontWeight(.bold)

                    // Completion button
                    Button(action: {
                        isCompleted.toggle()
                        if isCompleted {
                            progressTracker.completeItem(objective.id, category: .roe)
                        } else {
                            progressTracker.uncompleteItem(objective.id, category: .roe)
                        }
                    }) {
                        HStack {
                            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            Text(isCompleted ? "Completed" : "Mark as Complete")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isCompleted ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                        .foregroundColor(isCompleted ? .green : .blue)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)

                // Objective details
                VStack(alignment: .leading, spacing: 16) {
                    DetailSection(title: "Description", icon: "text.alignleft") {
                        Text(objective.description)
                            .font(.body)
                    }

                    if let count = objective.objectiveCount {
                        DetailSection(title: "Objective Count", icon: "number") {
                            Text("\(count)")
                                .font(.body)
                        }
                    }

                    DetailSection(title: "Type", icon: "tag") {
                        HStack(spacing: 8) {
                            if objective.repeatable {
                                Label("Repeatable", systemImage: "arrow.clockwise")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                                    .font(.caption)
                            } else {
                                Label("One-time", systemImage: "checkmark.circle")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .cornerRadius(8)
                                    .font(.caption)
                            }
                        }
                    }

                    DetailSection(title: "Category", icon: "folder") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(objective.category) - \(objective.subcategory)")
                                .font(.body)

                            // Show unlock info if available
                            if let unlockInfo = ROEUnlockManager.shared.getUnlockInfo(for: objective.category, subcategory: objective.subcategory) {
                                Divider()
                                    .padding(.vertical, 4)

                                HStack(spacing: 6) {
                                    Image(systemName: ROEUnlockManager.shared.getUnlockRequirement(for: objective.category, subcategory: objective.subcategory).icon)
                                        .foregroundColor(.blue)
                                    Text("Unlock: \(unlockInfo)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }

                                if let notes = ROEUnlockManager.shared.getNotes(for: objective.category, subcategory: objective.subcategory) {
                                    HStack(alignment: .top, spacing: 6) {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.green)
                                        Text(notes)
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }

                    // NPCs section
                    if let npcs = objective.npcs, !npcs.isEmpty {
                        DetailSection(title: "Related NPCs & Info", icon: "person.2") {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(npcs, id: \.name) { npc in
                                    HStack {
                                        Text("•")
                                        Text(npc.name)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }

                    // Rewards section
                    if let rewards = objective.rewards {
                        DetailSection(title: "Rewards", icon: "gift") {
                            VStack(alignment: .leading, spacing: 12) {
                                if let sparks = rewards.sparks {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .foregroundColor(.orange)
                                        Text("Sparks of Eminence:")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("\(sparks)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.orange)
                                    }
                                }

                                if let exp = rewards.exp {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text("Experience Points:")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("\(exp)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.yellow)
                                    }
                                }

                                if let accolades = rewards.accolades {
                                    HStack {
                                        Image(systemName: "star.circle.fill")
                                            .foregroundColor(.purple)
                                        Text("Unity Accolades:")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("\(accolades)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.purple)
                                    }
                                }

                                if let items = rewards.items, !items.isEmpty {
                                    Divider()
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "cube.box.fill")
                                                .foregroundColor(.blue)
                                            Text("Items:")
                                                .fontWeight(.medium)
                                        }

                                        ForEach(items, id: \.name) { item in
                                            HStack {
                                                Text("•")
                                                Text(item.name)
                                                Spacer()
                                            }
                                            .padding(.leading, 24)
                                        }
                                    }
                                }

                                if !objective.hasRewards {
                                    Text("No reward information available")
                                        .foregroundColor(.secondary)
                                        .italic()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle("Objective Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
            }

            content
                .padding(.leading, 22)
        }
    }
}

#Preview {
    NavigationStack {
        ROEObjectiveDetailView(
            objective: ROEObjective(
                name: "Test Objective",
                category: "Tutorial",
                subcategory: "Basics",
                description: "Complete a basic task",
                objectiveCount: 10,
                repeatable: true,
                rewards: ROERewards(
                    sparks: 100,
                    exp: 500,
                    accolades: nil,
                    items: [ROERewardItem(name: "Test Item")]
                ),
                npcs: nil
            ),
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
