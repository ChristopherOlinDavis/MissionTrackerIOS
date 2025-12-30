//
//  ChecklistModeView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/30/25.
//

import SwiftUI

struct ChecklistModeView: View {
    @Bindable var progressTracker: MissionProgressTracker
    let missionSets: [MissionSet]
    let questSets: [MissionSet]

    @State private var selectedView: ChecklistViewType = .incomplete
    @State private var showMissions = true
    @State private var showQuests = true

    enum ChecklistViewType: String, CaseIterable {
        case incomplete = "In Progress"
        case completed = "Completed"
        case all = "All"
    }

    private var incompleteMissions: [(mission: Mission, setName: String, isMission: Bool)] {
        var results: [(mission: Mission, setName: String, isMission: Bool)] = []

        if showMissions {
            for set in missionSets {
                for mission in set.missions {
                    if !progressTracker.isMissionCompleted(mission) {
                        let progress = progressTracker.missionProgress(mission)
                        // Only show missions that have at least one node completed or can be started
                        if progress > 0 || mission.nodes.first?.canStart(completedNodeIds: progressTracker.completedNodes) == true {
                            results.append((mission, set.name, true))
                        }
                    }
                }
            }
        }

        if showQuests {
            for set in questSets {
                for mission in set.missions {
                    if !progressTracker.isMissionCompleted(mission) {
                        let progress = progressTracker.missionProgress(mission)
                        if progress > 0 || mission.nodes.first?.canStart(completedNodeIds: progressTracker.completedNodes) == true {
                            results.append((mission, set.name, false))
                        }
                    }
                }
            }
        }

        return results.sorted(by: { $0.mission.title < $1.mission.title })
    }

    private var completedMissions: [(mission: Mission, setName: String, isMission: Bool)] {
        var results: [(mission: Mission, setName: String, isMission: Bool)] = []

        if showMissions {
            for set in missionSets {
                for mission in set.missions {
                    if progressTracker.isMissionCompleted(mission) {
                        results.append((mission, set.name, true))
                    }
                }
            }
        }

        if showQuests {
            for set in questSets {
                for mission in set.missions {
                    if progressTracker.isMissionCompleted(mission) {
                        results.append((mission, set.name, false))
                    }
                }
            }
        }

        return results.sorted(by: { $0.mission.title < $1.mission.title })
    }

    private var allMissions: [(mission: Mission, setName: String, isMission: Bool)] {
        var results: [(mission: Mission, setName: String, isMission: Bool)] = []

        if showMissions {
            for set in missionSets {
                for mission in set.missions {
                    results.append((mission, set.name, true))
                }
            }
        }

        if showQuests {
            for set in questSets {
                for mission in set.missions {
                    results.append((mission, set.name, false))
                }
            }
        }

        return results.sorted(by: { $0.mission.title < $1.mission.title })
    }

    private var displayedMissions: [(mission: Mission, setName: String, isMission: Bool)] {
        switch selectedView {
        case .incomplete:
            return incompleteMissions
        case .completed:
            return completedMissions
        case .all:
            return allMissions
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // View type picker
            Picker("View", selection: $selectedView) {
                ForEach(ChecklistViewType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Content type toggles
            HStack(spacing: 16) {
                Toggle(isOn: $showMissions) {
                    Label("Missions", systemImage: "flag.fill")
                        .font(.caption)
                }
                .toggleStyle(.button)
                .tint(.purple)

                Toggle(isOn: $showQuests) {
                    Label("Quests", systemImage: "star.fill")
                        .font(.caption)
                }
                .toggleStyle(.button)
                .tint(.orange)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)

            Divider()

            // Checklist
            if displayedMissions.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: selectedView == .incomplete ? "checkmark.circle.fill" : "list.bullet")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)

                    Text(selectedView == .incomplete ? "No in-progress items" : "No items found")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    if selectedView == .incomplete {
                        Text("Start a mission or quest to see it here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            } else {
                List {
                    Section {
                        Text("\(displayedMissions.count) item(s)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ForEach(displayedMissions, id: \.mission.id) { item in
                        ChecklistItemView(
                            mission: item.mission,
                            setName: item.setName,
                            isMission: item.isMission,
                            progressTracker: progressTracker
                        )
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Checklist")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct ChecklistItemView: View {
    let mission: Mission
    let setName: String
    let isMission: Bool
    @Bindable var progressTracker: MissionProgressTracker

    @State private var isExpanded = false

    private var progress: Double {
        progressTracker.missionProgress(mission)
    }

    private var isCompleted: Bool {
        progressTracker.isMissionCompleted(mission)
    }

    private var incompleteNodes: [MissionNode] {
        mission.nodes.filter { !progressTracker.isCompleted($0.id) }
    }

    private var completedNodeCount: Int {
        mission.nodes.filter { progressTracker.isCompleted($0.id) }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header - tappable to expand/collapse
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    // Expand indicator
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 16)

                    VStack(alignment: .leading, spacing: 4) {
                        // Title
                        Text(mission.title)
                            .font(.headline)
                            .foregroundColor(isCompleted ? .secondary : .primary)
                            .strikethrough(isCompleted, color: .secondary)

                        // Set name and type
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

                            Text(setName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Progress indicator
                    VStack(alignment: .trailing, spacing: 2) {
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Text("\(completedNodeCount)/\(mission.nodes.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            ProgressView(value: progress)
                                .frame(width: 50)
                                .tint(.blue)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            // Expanded node list
            if isExpanded && !mission.nodes.isEmpty {
                Divider()
                    .padding(.leading, 16)

                ForEach(mission.nodes) { node in
                    NodeChecklistRow(
                        node: node,
                        isCompleted: progressTracker.isCompleted(node.id),
                        canStart: node.canStart(completedNodeIds: progressTracker.completedNodes)
                    ) {
                        progressTracker.toggleNode(node.id)
                    }
                    .padding(.leading, 32)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct NodeChecklistRow: View {
    let node: MissionNode
    let isCompleted: Bool
    let canStart: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : (canStart ? .blue : .gray))
                    .font(.title3)
            }
            .disabled(!canStart && !isCompleted)

            VStack(alignment: .leading, spacing: 2) {
                Text(node.title)
                    .font(.subheadline)
                    .strikethrough(isCompleted, color: .secondary)
                    .foregroundColor(isCompleted ? .secondary : .primary)

                if let location = node.location, let zone = location.zone {
                    HStack(spacing: 4) {
                        Image(systemName: "map")
                            .font(.caption2)
                        Text(zone)
                            .font(.caption)

                        if let coords = location.coordinates {
                            Text("•")
                            Text(coords)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.blue)
                }
            }

            Spacer()
        }
        .opacity(canStart || isCompleted ? 1.0 : 0.6)
    }
}

#Preview {
    NavigationStack {
        ChecklistModeView(
            progressTracker: MissionProgressTracker(characterManager: CharacterManager()),
            missionSets: [],
            questSets: []
        )
    }
}
