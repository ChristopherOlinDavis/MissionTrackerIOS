//
//  ROECategoryListView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import SwiftUI

struct ROECategoryListView: View {
    let roeLoader: ROEDataLoader
    @Bindable var progressTracker: MissionProgressTracker

    @State private var searchText = ""
    @State private var showCompletedOnly = false
    @State private var showIncompleteOnly = false

    private var allObjectives: [(objective: ROEObjective, categoryName: String, subcategoryName: String)] {
        var results: [(objective: ROEObjective, categoryName: String, subcategoryName: String)] = []
        for category in roeLoader.categoryGroups {
            for subcategory in category.subcategories {
                for objective in subcategory.objectives {
                    results.append((objective, category.name, subcategory.name))
                }
            }
        }
        return results
    }

    private var filteredObjectives: [(objective: ROEObjective, categoryName: String, subcategoryName: String)] {
        var filtered = allObjectives

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                let objective = item.objective

                // Search in name
                if objective.name.localizedCaseInsensitiveContains(searchText) {
                    return true
                }

                // Search in description
                if objective.description.localizedCaseInsensitiveContains(searchText) {
                    return true
                }

                // Search in category/subcategory
                if item.categoryName.localizedCaseInsensitiveContains(searchText) {
                    return true
                }

                if item.subcategoryName.localizedCaseInsensitiveContains(searchText) {
                    return true
                }

                // Search in reward items
                if let items = objective.rewards?.items {
                    if items.contains(where: { $0.name.localizedCaseInsensitiveContains(searchText) }) {
                        return true
                    }
                }

                return false
            }
        }

        // Apply completion filters
        if showCompletedOnly {
            filtered = filtered.filter { progressTracker.isItemCompleted($0.objective.id, category: .roe) }
        } else if showIncompleteOnly {
            filtered = filtered.filter { !progressTracker.isItemCompleted($0.objective.id, category: .roe) }
        }

        return filtered
    }

    private var groupedObjectives: [String: [(objective: ROEObjective, categoryName: String, subcategoryName: String)]] {
        Dictionary(grouping: filteredObjectives, by: { "\($0.categoryName) - \($0.subcategoryName)" })
    }

    private var shouldShowSearchResults: Bool {
        !searchText.isEmpty || showCompletedOnly || showIncompleteOnly
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search and filters
            VStack(spacing: 12) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search objectives, rewards...", text: $searchText)
                        .textFieldStyle(.plain)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)

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
            }
            .padding()

            Divider()

            // Results
            if shouldShowSearchResults {
                // Search results view
                if filteredObjectives.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)

                        Text("No results found")
                            .font(.title3)
                            .foregroundColor(.secondary)

                        Text("Try different keywords or filters")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                } else {
                    List {
                        Section {
                            Text("\(filteredObjectives.count) objective(s)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        ForEach(Array(groupedObjectives.keys.sorted()), id: \.self) { groupKey in
                            Section(header: Text(groupKey)) {
                                ForEach(groupedObjectives[groupKey] ?? [], id: \.objective.id) { item in
                                    NavigationLink {
                                        ROEObjectiveDetailView(
                                            objective: item.objective,
                                            progressTracker: progressTracker
                                        )
                                    } label: {
                                        ROEObjectiveRow(
                                            objective: item.objective,
                                            isCompleted: progressTracker.isItemCompleted(item.objective.id, category: .roe)
                                        )
                                    }
                                }
                            }
                        }
                    }
                    #if os(iOS)
                    .listStyle(.insetGrouped)
                    #endif
                }
            } else {
                // Default category view
                List(roeLoader.categoryGroups) { category in
                    NavigationLink(destination: ROESubcategoryListView(
                        category: category,
                        progressTracker: progressTracker
                    )) {
                        ROECategoryRow(
                            category: category,
                            progressTracker: progressTracker
                        )
                    }
                }
            }
        }
        .navigationTitle("Records of Eminence")
    }
}

struct ROECategoryRow: View {
    let category: ROECategoryGroup
    let progressTracker: MissionProgressTracker

    private var completedObjectives: Int {
        category.subcategories.flatMap { $0.objectives }.filter {
            progressTracker.isItemCompleted($0.id, category: .roe)
        }.count
    }

    private var totalObjectives: Int {
        category.totalObjectives
    }

    private var completionPercentage: Double {
        totalObjectives > 0 ? Double(completedObjectives) / Double(totalObjectives) : 0
    }

    private var unlockInfo: String? {
        ROEUnlockManager.shared.getUnlockInfo(for: category.name)
    }

    private var totalCompletedROEs: Int {
        progressTracker.completedROEs.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.name)
                .font(.headline)

            // Show unlock requirement if any
            if let unlockInfo = unlockInfo {
                HStack(spacing: 4) {
                    Image(systemName: ROEUnlockManager.shared.getUnlockRequirement(for: category.name).icon)
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text(unlockInfo)
                        .font(.caption2)
                        .foregroundColor(.blue)
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

struct ROEObjectiveRow: View {
    let objective: ROEObjective
    let isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(objective.name)
                    .font(.headline)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                    .strikethrough(isCompleted, color: .secondary)

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }

            Text(objective.description)
                .font(.caption)
                .foregroundColor(.secondary)

            if objective.repeatable {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption2)
                    Text("Repeatable")
                        .font(.caption2)
                }
                .foregroundColor(.blue)
            }

            if let rewards = objective.rewards {
                HStack(spacing: 8) {
                    if let sparks = rewards.sparks {
                        Label("\(sparks)", systemImage: "sparkles")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    if let accolades = rewards.accolades {
                        Label("\(accolades)", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.purple)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ROECategoryListView(
            roeLoader: ROEDataLoader(),
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
