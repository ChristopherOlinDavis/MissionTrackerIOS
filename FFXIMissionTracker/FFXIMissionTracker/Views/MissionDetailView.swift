//
//  MissionDetailView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import SwiftUI

struct MissionDetailView: View {
    let mission: Mission
    @Bindable var progressTracker: MissionProgressTracker

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    if let number = mission.number {
                        Text("Mission \(number)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(mission.title)
                        .font(.title2)
                        .bold()

                    // Zones
                    if !mission.zones.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(mission.zones, id: \.self) { zone in
                                    Label(zone, systemImage: "map")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }

                    // Progress
                    let progress = progressTracker.missionProgress(mission)
                    HStack {
                        Text("\(Int(progress * 100))% Complete")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        if progressTracker.isMissionCompleted(mission) {
                            Label("Completed", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }

                    ProgressView(value: progress)
                        .tint(progressTracker.isMissionCompleted(mission) ? .green : .blue)
                }
                .padding()

                Divider()

                // Node Steps
                ForEach(mission.nodes) { node in
                    NodeStepView(
                        node: node,
                        isCompleted: progressTracker.isCompleted(node.id),
                        canStart: node.canStart(completedNodeIds: progressTracker.completedNodes)
                    ) {
                        progressTracker.toggleNode(node.id)
                    }
                }

                // Gates (if any)
                if !mission.gates.isEmpty {
                    Divider()
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Requirements & Gates")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(mission.gates) { gate in
                            GateView(gate: gate)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NodeStepView: View {
    let node: MissionNode
    let isCompleted: Bool
    let canStart: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Checkbox
                Button(action: onToggle) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : (canStart ? .blue : .gray))
                        .font(.title2)
                }
                .disabled(!canStart && !isCompleted)

                VStack(alignment: .leading, spacing: 6) {
                    // Step number
                    Text("Step \(node.orderIndex + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Title
                    Text(node.title)
                        .font(.headline)
                        .strikethrough(isCompleted, color: .secondary)

                    // Description (if different from title)
                    if node.description != node.title {
                        Text(node.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    // Location info
                    if let location = node.location {
                        HStack(spacing: 4) {
                            if let zone = location.zone {
                                Label(zone, systemImage: "map")
                                    .font(.caption)
                            }

                            if let coords = location.coordinates {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text(coords)
                                    .font(.caption.monospaced())
                            }

                            if let npc = location.npc {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Label(npc, systemImage: "person")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.blue)
                    }

                    // Dependencies indicator
                    if !node.dependencies.isEmpty && !isCompleted {
                        Text("Requires \(node.dependencies.count) previous step(s)")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCompleted ? Color.green : (canStart ? Color.blue : Color.clear), lineWidth: 2)
            )
            .opacity(canStart || isCompleted ? 1.0 : 0.6)
        }
        .padding(.horizontal)
    }
}

struct GateView: View {
    let gate: Gate

    private var icon: String {
        switch gate.type {
        case .level:
            return "chart.bar.fill"
        case .mission:
            return "flag.fill"
        case .missionSet:
            return "flag.2.crossed.fill"
        case .item:
            return "cube.box.fill"
        case .node:
            return "circle.fill"
        case .other:
            return "exclamationmark.triangle.fill"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(gate.requirement)
                    .font(.headline)

                Text(gate.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        MissionDetailView(
            mission: Mission(
                id: "test",
                title: "Test Mission",
                number: "1-1",
                url: nil,
                nodes: [
                    MissionNode(
                        id: "node1",
                        orderIndex: 0,
                        title: "Talk to guard",
                        description: "Talk to the guard in Bastok",
                        dependencies: [],
                        location: Location(
                            coordinates: "H-9",
                            zone: "Bastok Mines",
                            npc: "Guard"
                        )
                    )
                ],
                gates: []
            ),
            progressTracker: MissionProgressTracker()
        )
    }
}
