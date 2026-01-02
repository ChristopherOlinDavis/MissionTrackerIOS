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
    @State private var selectedImage: MissionImage?
    @State private var showingImageViewer = false

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

                // Images (if any)
                if let images = mission.images, !images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(images.indices, id: \.self) { index in
                                Button {
                                    selectedImage = images[index]
                                    showingImageViewer = true
                                } label: {
                                    AsyncImage(url: URL(string: images[index].src)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 200)
                                                .cornerRadius(8)
                                        case .failure(_):
                                            Image(systemName: "photo")
                                                .frame(width: 200, height: 200)
                                                .foregroundColor(.gray)
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 200, height: 200)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 220)
                }

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

                // Rewards (if any)
                if let rewards = mission.rewards, !rewards.isEmpty {
                    Divider()
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rewards")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(rewards, id: \.name) { reward in
                            HStack(spacing: 8) {
                                Image(systemName: "gift.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)

                                Text(reward.name)
                                    .font(.subheadline)

                                if let type = reward.type {
                                    Text("(\(type))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        }
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
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                if let urlString = mission.url, let url = URL(string: urlString) {
                    Link(destination: url) {
                        Label("Wiki", systemImage: "link.circle")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                if let urlString = mission.url, let url = URL(string: urlString) {
                    Link(destination: url) {
                        Label("Wiki", systemImage: "link.circle")
                    }
                }
            }
            #endif
        }
        .sheet(isPresented: $showingImageViewer) {
            if let selectedImage = selectedImage {
                ImageViewerSheet(image: selectedImage)
            }
        }
    }
}

struct ImageViewerSheet: View {
    let image: MissionImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZoomableImageView(imageURL: URL(string: image.src))
                .navigationTitle(image.alt.isEmpty ? "Image" : image.alt)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct ZoomableImageView: View {
    let imageURL: URL?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                        if scale < 1 {
                                            withAnimation {
                                                scale = 1
                                                lastScale = 1
                                                offset = .zero
                                                lastOffset = .zero
                                            }
                                        } else if scale > 5 {
                                            withAnimation {
                                                scale = 5
                                                lastScale = 5
                                            }
                                        }
                                    }
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    if scale > 1 {
                                        scale = 1
                                        lastScale = 1
                                        offset = .zero
                                        lastOffset = .zero
                                    } else {
                                        scale = 2
                                        lastScale = 2
                                    }
                                }
                            }
                    case .failure(_):
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("Failed to load image")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
            }
        }
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
                gates: [],
                htmlFile: nil,
                images: nil,
                nation: nil,
                rewards: nil
            ),
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
