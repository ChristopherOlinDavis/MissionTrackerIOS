//
//  UNMDetailView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import SwiftUI

struct UNMDetailView: View {
    let nm: UnityNotoriousMonster
    @Bindable var progressTracker: MissionProgressTracker

    @State private var isCompleted: Bool

    init(nm: UnityNotoriousMonster, progressTracker: MissionProgressTracker) {
        self.nm = nm
        self.progressTracker = progressTracker
        _isCompleted = State(initialValue: progressTracker.isItemCompleted(nm.id, category: .unityNM))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with completion button
                VStack(alignment: .leading, spacing: 16) {
                    Text(nm.nm)
                        .font(.title)
                        .fontWeight(.bold)

                    HStack(spacing: 16) {
                        Label(nm.levelDisplay, systemImage: "chart.line.uptrend.xyaxis")
                            .font(.subheadline)
                            .foregroundColor(.orange)

                        Label(nm.accoladesDisplay, systemImage: "star.fill")
                            .font(.subheadline)
                            .foregroundColor(.purple)

                        Label(nm.category, systemImage: "tag")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }

                    // Completion button
                    Button(action: {
                        isCompleted.toggle()
                        if isCompleted {
                            progressTracker.completeItem(nm.id, category: .unityNM)
                        } else {
                            progressTracker.uncompleteItem(nm.id, category: .unityNM)
                        }
                    }) {
                        HStack {
                            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            Text(isCompleted ? "Defeated" : "Mark as Defeated")
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

                // Location details
                VStack(alignment: .leading, spacing: 16) {
                    DetailSection(title: "Location", icon: "map.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Zone:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(nm.zone)
                                    .foregroundColor(.blue)
                            }

                            HStack {
                                Text("Unity Warp:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(nm.unityWarp)
                                    .foregroundColor(.green)
                            }

                            Divider()

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.orange)
                                    Text("Ethereal Junctions:")
                                        .fontWeight(.medium)
                                }

                                Text(nm.junctionsDisplay)
                                    .font(.body)
                                    .padding(.leading, 24)
                            }
                        }
                    }

                    // Point rewards
                    DetailSection(title: "Point Rewards", icon: "star.circle.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.orange)
                                Text("Sparks of Eminence:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(nm.pointRewards.sparks)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }

                            if nm.pointRewards.exp > 0 {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text("Experience Points:")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("\(nm.pointRewards.exp)")
                                        .fontWeight(.bold)
                                        .foregroundColor(.yellow)
                                }
                            }

                            if nm.pointRewards.cp > 0 {
                                HStack {
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.cyan)
                                    Text("Capacity Points:")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("\(nm.pointRewards.cp)")
                                        .fontWeight(.bold)
                                        .foregroundColor(.cyan)
                                }
                            }
                        }
                    }

                    // Notable rewards
                    if !nm.notableRewards.isEmpty {
                        DetailSection(title: "Notable Item Rewards", icon: "gift.fill") {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(nm.notableRewards) { reward in
                                    HStack {
                                        Text("•")
                                        Text(reward.item)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle("Unity NM Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        UNMDetailView(
            nm: UnityNotoriousMonster(
                level: 99,
                accolades: 400,
                nm: "Test Monster",
                zone: "Test Zone",
                category: "Wanted 1",
                etherealJunctions: .simple(["E-7", "G-8", "H-9"]),
                unityWarp: "G-8",
                pointRewards: UNMPointRewards(sparks: 750, exp: 4000, cp: 0),
                notableRewards: [
                    UNMNotableReward(item: "Test Item 1", url: "/test1"),
                    UNMNotableReward(item: "Test Item 2", url: "/test2")
                ]
            ),
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
