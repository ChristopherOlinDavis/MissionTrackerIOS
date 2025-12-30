//
//  SearchFilterView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/30/25.
//

import SwiftUI

struct SearchFilterView: View {
    @Bindable var progressTracker: MissionProgressTracker
    let missionSets: [MissionSet]
    let questSets: [MissionSet]

    @State private var searchText = ""
    @State private var selectedCategory: ContentCategory = .all
    @State private var showCompletedOnly = false
    @State private var showIncompleteOnly = false

    enum ContentCategory: String, CaseIterable {
        case all = "All"
        case missions = "Missions"
        case quests = "Quests"
    }

    private var allMissions: [(mission: Mission, setName: String, isMission: Bool)] {
        var results: [(Mission, String, Bool)] = []

        if selectedCategory == .all || selectedCategory == .missions {
            for set in missionSets {
                for mission in set.missions {
                    results.append((mission, set.name, true))
                }
            }
        }

        if selectedCategory == .all || selectedCategory == .quests {
            for set in questSets {
                for mission in set.missions {
                    results.append((mission, set.name, false))
                }
            }
        }

        return results
    }

    private var filteredMissions: [(mission: Mission, setName: String, isMission: Bool)] {
        var filtered = allMissions

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                let mission = item.mission

                // Search in title
                if mission.title.localizedCaseInsensitiveContains(searchText) {
                    return true
                }

                // Search in zones
                if mission.zones.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) {
                    return true
                }

                // Search in rewards
                if let rewards = mission.rewards {
                    if rewards.contains(where: { $0.name.localizedCaseInsensitiveContains(searchText) }) {
                        return true
                    }
                }

                // Search in node descriptions
                if mission.nodes.contains(where: {
                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.description.localizedCaseInsensitiveContains(searchText)
                }) {
                    return true
                }

                return false
            }
        }

        // Apply completion filters
        if showCompletedOnly {
            filtered = filtered.filter { progressTracker.isMissionCompleted($0.mission) }
        } else if showIncompleteOnly {
            filtered = filtered.filter { !progressTracker.isMissionCompleted($0.mission) }
        }

        return filtered
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar and filters
            VStack(spacing: 12) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search missions, zones, rewards...", text: $searchText)
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

                // Category picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(ContentCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)

                // Completion filters
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
            if filteredMissions.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)

                    Text(searchText.isEmpty ? "Enter a search term" : "No results found")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    if !searchText.isEmpty {
                        Text("Try different keywords or filters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            } else {
                List {
                    Section {
                        Text("\(filteredMissions.count) result(s)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ForEach(filteredMissions, id: \.mission.id) { item in
                        NavigationLink {
                            MissionDetailView(
                                mission: item.mission,
                                progressTracker: progressTracker
                            )
                        } label: {
                            SearchResultRow(
                                mission: item.mission,
                                setName: item.setName,
                                isMission: item.isMission,
                                isCompleted: progressTracker.isMissionCompleted(item.mission),
                                searchText: searchText
                            )
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Search & Filter")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SearchResultRow: View {
    let mission: Mission
    let setName: String
    let isMission: Bool
    let isCompleted: Bool
    let searchText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title
            HStack {
                Text(mission.title)
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

            // Mission number and type
            HStack(spacing: 8) {
                if let number = mission.number {
                    Text(number)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }

                Text(isMission ? "Mission" : "Quest")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background((isMission ? Color.purple : Color.orange).opacity(0.2))
                    .cornerRadius(4)
            }

            // Set name
            Text(setName)
                .font(.caption)
                .foregroundColor(.secondary)

            // Matching zones if search contains zone
            if !searchText.isEmpty && !mission.zones.isEmpty {
                let matchingZones = mission.zones.filter { $0.localizedCaseInsensitiveContains(searchText) }
                if !matchingZones.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "map")
                            .font(.caption2)
                        Text(matchingZones.joined(separator: ", "))
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }

            // Matching rewards if search contains reward
            if !searchText.isEmpty, let rewards = mission.rewards {
                let matchingRewards = rewards.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                if !matchingRewards.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.caption2)
                        Text(matchingRewards.map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color.opacity(0.2) : Color.secondary.opacity(0.1))
            .foregroundColor(isSelected ? color : .secondary)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 1)
            )
        }
    }
}

#Preview {
    NavigationStack {
        SearchFilterView(
            progressTracker: MissionProgressTracker(characterManager: CharacterManager()),
            missionSets: [],
            questSets: []
        )
    }
}
