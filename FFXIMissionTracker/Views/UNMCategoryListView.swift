//
//  UNMCategoryListView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import SwiftUI

struct UNMCategoryListView: View {
    let unmLoader: UnityNMDataLoader
    @Bindable var progressTracker: MissionProgressTracker

    @State private var searchText = ""
    @State private var showCompletedOnly = false
    @State private var showIncompleteOnly = false

    private var allNMs: [(nm: UnityNotoriousMonster, categoryName: String)] {
        var results: [(nm: UnityNotoriousMonster, categoryName: String)] = []
        for category in unmLoader.categoryGroups {
            for nm in category.nms {
                results.append((nm, category.name))
            }
        }
        return results
    }

    private var filteredNMs: [(nm: UnityNotoriousMonster, categoryName: String)] {
        var filtered = allNMs

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                let nm = item.nm

                // Search in name
                if nm.nm.localizedCaseInsensitiveContains(searchText) {
                    return true
                }

                // Search in zone
                if nm.zone.localizedCaseInsensitiveContains(searchText) {
                    return true
                }

                // Search in category
                if item.categoryName.localizedCaseInsensitiveContains(searchText) {
                    return true
                }

                // Search in rewards
                if nm.notableRewards.contains(where: { $0.item.localizedCaseInsensitiveContains(searchText) }) {
                    return true
                }

                return false
            }
        }

        // Apply completion filters
        if showCompletedOnly {
            filtered = filtered.filter { progressTracker.isItemCompleted($0.nm.id, category: .unityNM) }
        } else if showIncompleteOnly {
            filtered = filtered.filter { !progressTracker.isItemCompleted($0.nm.id, category: .unityNM) }
        }

        return filtered
    }

    private var groupedNMs: [String: [(nm: UnityNotoriousMonster, categoryName: String)]] {
        Dictionary(grouping: filteredNMs, by: { $0.categoryName })
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
                    TextField("Search NMs, zones, rewards...", text: $searchText)
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
                if filteredNMs.isEmpty {
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
                            Text("\(filteredNMs.count) Unity NM(s)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        ForEach(Array(groupedNMs.keys.sorted()), id: \.self) { categoryName in
                            Section(header: Text(categoryName)) {
                                ForEach(groupedNMs[categoryName] ?? [], id: \.nm.id) { item in
                                    NavigationLink {
                                        UNMDetailView(
                                            nm: item.nm,
                                            progressTracker: progressTracker
                                        )
                                    } label: {
                                        UNMRow(
                                            nm: item.nm,
                                            isCompleted: progressTracker.isItemCompleted(item.nm.id, category: .unityNM)
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
                List(unmLoader.categoryGroups) { category in
                    NavigationLink(destination: UNMListView(
                        category: category,
                        progressTracker: progressTracker
                    )) {
                        UNMCategoryRow(
                            category: category,
                            progressTracker: progressTracker
                        )
                    }
                }
            }
        }
        .navigationTitle("Unity Notorious Monsters")
    }
}

struct UNMCategoryRow: View {
    let category: UNMCategoryGroup
    let progressTracker: MissionProgressTracker

    private var completedNMs: Int {
        category.nms.filter {
            progressTracker.isItemCompleted($0.id, category: .unityNM)
        }.count
    }

    private var totalNMs: Int {
        category.nms.count
    }

    private var completionPercentage: Double {
        totalNMs > 0 ? Double(completedNMs) / Double(totalNMs) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.displayName)
                .font(.headline)

            HStack(spacing: 16) {
                Label(category.levelRange, systemImage: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                    .foregroundColor(.blue)

                Label("\(category.accoladeRange) accolades", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.purple)
            }

            HStack {
                Label("\(totalNMs) NMs", systemImage: "flag.2.crossed")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(completedNMs)/\(totalNMs)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: completionPercentage)
                .tint(.purple)
        }
        .padding(.vertical, 4)
    }
}

struct UNMRow: View {
    let nm: UnityNotoriousMonster
    let isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(nm.nm)
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

            HStack(spacing: 4) {
                Image(systemName: "map")
                    .font(.caption2)
                Text(nm.zone)
                    .font(.caption)
            }
            .foregroundColor(.blue)

            HStack(spacing: 12) {
                Label(nm.levelDisplay, systemImage: "chart.line.uptrend.xyaxis")
                    .font(.caption2)
                    .foregroundColor(.orange)

                Label(nm.accoladesDisplay, systemImage: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.purple)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        UNMCategoryListView(
            unmLoader: UnityNMDataLoader(),
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
