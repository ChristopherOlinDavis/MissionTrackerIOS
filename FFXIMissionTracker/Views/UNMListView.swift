//
//  UNMListView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import SwiftUI

struct UNMListView: View {
    let category: UNMCategoryGroup
    @Bindable var progressTracker: MissionProgressTracker

    @State private var showCompletedOnly = false
    @State private var showIncompleteOnly = false

    private var filteredNMs: [UnityNotoriousMonster] {
        var nms = category.nms

        if showCompletedOnly {
            nms = nms.filter { progressTracker.isItemCompleted($0.id, category: .unityNM) }
        } else if showIncompleteOnly {
            nms = nms.filter { !progressTracker.isItemCompleted($0.id, category: .unityNM) }
        }

        return nms
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

            if filteredNMs.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "flag.2.crossed")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)

                    Text("No Unity NMs")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text("Try adjusting your filters")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredNMs) { nm in
                        NavigationLink {
                            UNMDetailView(
                                nm: nm,
                                progressTracker: progressTracker
                            )
                        } label: {
                            UNMRow(
                                nm: nm,
                                isCompleted: progressTracker.isItemCompleted(nm.id, category: .unityNM)
                            )
                        }
                    }
                }
                #if os(iOS)
                .listStyle(.insetGrouped)
                #endif
            }
        }
        .navigationTitle(category.displayName)
    }
}

#Preview {
    NavigationStack {
        UNMListView(
            category: UNMCategoryGroup(name: "Test Category", nms: []),
            progressTracker: MissionProgressTracker(characterManager: CharacterManager())
        )
    }
}
