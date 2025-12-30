//
//  QuestsTabView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import SwiftUI

struct QuestsTabView: View {
    @State private var questSets: [MissionSet] = []
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
                        ProgressView("Loading quests...")
                    } else if let error = errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)

                            Text("Error Loading Quests")
                                .font(.headline)

                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Button("Retry") {
                                loadQuests()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else if questSets.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)

                            Text("No Quests Found")
                                .font(.headline)

                            Text("Add quest JSON files to the app bundle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        QuestSetListView(
                            questSets: questSets,
                            progressTracker: progressTracker
                        )
                    }
                }

                // Footer
                FooterView()
            }
            .navigationTitle("FFXI Quests")
        }
        .onAppear {
            loadQuests()
        }
    }

    private func loadQuests() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let sets = try MissionDataLoader.shared.loadAllQuestSets()
                await MainActor.run {
                    self.questSets = sets
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
