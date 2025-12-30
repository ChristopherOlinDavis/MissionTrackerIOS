//
//  MissionsTabView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import SwiftUI

struct MissionsTabView: View {
    @State private var missionSets: [MissionSet] = []
    @Binding var progressTracker: MissionProgressTracker
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HeaderView(
                    characterManager: progressTracker.characterManager,
                    onCharacterChange: { progressTracker.refreshProgress() }
                )

                // Content
                Group {
                    if isLoading {
                        ProgressView("Loading missions...")
                    } else if let error = errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)

                            Text("Error Loading Missions")
                                .font(.headline)

                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Button("Retry") {
                                loadMissions()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else if missionSets.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)

                            Text("No Missions Found")
                                .font(.headline)

                            Text("Add mission JSON files to the app bundle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        MissionSetListView(
                            missionSets: missionSets,
                            progressTracker: progressTracker
                        )
                    }
                }

                // Footer
                FooterView()
            }
            .navigationTitle("FFXI Missions")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            progressTracker.resetProgress()
                        } label: {
                            Label("Reset All Progress", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            progressTracker.resetProgress()
                        } label: {
                            Label("Reset All Progress", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                #endif
            }
        }
        .onAppear {
            loadMissions()
        }
    }

    private func loadMissions() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let sets = try MissionDataLoader.shared.loadAllMissionSets()
                await MainActor.run {
                    self.missionSets = sets
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
