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

    @State private var searchText = ""
    @State private var showCompletedOnly = false
    @State private var showIncompleteOnly = false

    private var allMissions: [(mission: Mission, setName: String)] {
        var results: [(mission: Mission, setName: String)] = []
        for set in missionSets {
            for mission in set.missions {
                results.append((mission, set.name))
            }
        }
        return results
    }

    private var filteredMissions: [(mission: Mission, setName: String)] {
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

    private var groupedMissions: [String: [(mission: Mission, setName: String)]] {
        Dictionary(grouping: filteredMissions, by: { $0.setName })
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
                if filteredMissions.isEmpty {
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
                            Text("\(filteredMissions.count) mission(s)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        ForEach(Array(groupedMissions.keys.sorted()), id: \.self) { setName in
                            Section(header: Text(setName)) {
                                ForEach(groupedMissions[setName] ?? [], id: \.mission.id) { item in
                                    NavigationLink {
                                        MissionDetailView(
                                            mission: item.mission,
                                            progressTracker: progressTracker
                                        )
                                    } label: {
                                        MissionSearchResultRow(
                                            mission: item.mission,
                                            isCompleted: progressTracker.isMissionCompleted(item.mission)
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
                // Default mission sets view
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
            }
        }
        .navigationTitle("FFXI Missions")
    }
}

struct MissionSearchResultRow: View {
    let mission: Mission
    let isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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

            if let number = mission.number {
                Text(number)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }

            if !mission.zones.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "map")
                        .font(.caption2)
                    Text(mission.zones.prefix(2).joined(separator: ", "))
                        .font(.caption)
                    if mission.zones.count > 2 {
                        Text("+ \(mission.zones.count - 2) more")
                            .font(.caption)
                    }
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
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

    private var setRequirements: [Gate] {
        // Get gates from first mission that are expansion/set-level requirements
        guard let firstMission = missionSet.missions.first else { return [] }
        return firstMission.gates.filter { gate in
            gate.type == .other && (
                gate.requirement.lowercased().contains("expansion") ||
                gate.requirement.lowercased().contains("rank")
            )
        }
    }

    private var isNationMission: Bool {
        missionSet.category == "nation"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(missionSet.name)
                .font(.headline)

            // Show nation mission indicator
            if isNationMission {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("Only one nation required")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }

            // Show set-level requirements if any
            if !setRequirements.isEmpty {
                ForEach(setRequirements) { gate in
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text(gate.requirement)
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }

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
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
