//
//  SettingsTabView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import SwiftUI

struct SettingsTabView: View {
    @Bindable var characterManager: CharacterManager
    @Binding var progressTracker: MissionProgressTracker
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingAddCharacter = false
    @State private var showingResetAlert = false
    @State private var missionSets: [MissionSet] = []
    @State private var questSets: [MissionSet] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HeaderView()

                // Content
                Form {
                    // Character Management
                    Section("Characters (\(characterManager.characters.count)/\(characterManager.characterLimit))") {
                        ForEach(characterManager.characters) { character in
                            CharacterRowView(
                                character: character,
                                isActive: character.id == characterManager.activeCharacter?.id,
                                onSelect: {
                                    characterManager.setActiveCharacter(id: character.id)
                                    progressTracker.refreshProgress()
                                }
                            )
                        }
                        .onDelete(perform: deleteCharacters)

                        if characterManager.canAddMoreCharacters {
                            Button {
                                showingAddCharacter = true
                            } label: {
                                Label("Add Character", systemImage: "plus.circle.fill")
                            }
                        }
                    }

                    // Appearance
                    Section("Appearance") {
                        Toggle(isOn: $isDarkMode) {
                            Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                        }
                    }

                    // Data Management
                    Section("Data Management") {
                        Button(role: .destructive) {
                            showingResetAlert = true
                        } label: {
                            Label("Reset Current Character Progress", systemImage: "arrow.counterclockwise")
                        }
                    }

                    // About
                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Mission Sets")
                            Spacer()
                            Text("12")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Quest Sets")
                            Spacer()
                            Text("9")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Total Objectives")
                            Spacer()
                            Text("1,486")
                                .foregroundColor(.secondary)
                        }
                    }

                    // Advanced Features
                    Section("Advanced Features") {
                        NavigationLink {
                            ProgressStatisticsView(
                                characterManager: characterManager,
                                progressTracker: $progressTracker,
                                missionSets: missionSets,
                                questSets: questSets
                            )
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.title3)
                                    .foregroundColor(.purple)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Progress Statistics")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("Detailed completion stats and charts per character")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        NavigationLink {
                            ExportImportView(
                                characterManager: characterManager,
                                progressTracker: $progressTracker
                            )
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "square.and.arrow.up.fill")
                                    .font(.title3)
                                    .foregroundColor(.green)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Export/Import")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("Backup and share character progress data")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // Footer
                FooterView()
            }
            .navigationTitle("Settings")
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .sheet(isPresented: $showingAddCharacter) {
                AddCharacterView(characterManager: characterManager)
            }
            .onAppear {
                if isLoading {
                    Task {
                        do {
                            let missions = try MissionDataLoader.shared.loadAllMissionSets()
                            let quests = try MissionDataLoader.shared.loadAllQuestSets()
                            await MainActor.run {
                                self.missionSets = missions
                                self.questSets = quests
                                self.isLoading = false
                            }
                        } catch {
                            print("Error loading mission/quest sets: \(error)")
                            await MainActor.run {
                                self.isLoading = false
                            }
                        }
                    }
                }
            }
            .alert("Reset Progress?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    progressTracker.resetProgress()
                }
            } message: {
                if let character = characterManager.activeCharacter {
                    Text("This will reset all progress for \(character.name). This cannot be undone.")
                }
            }
        }
    }

    private func deleteCharacters(at offsets: IndexSet) {
        for index in offsets {
            let character = characterManager.characters[index]
            characterManager.deleteCharacter(id: character.id)
        }
        progressTracker.refreshProgress()
    }
}

struct CharacterRowView: View {
    let character: Character
    let isActive: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 4) {
                        Image(systemName: "server.rack")
                            .font(.caption2)
                        Text(character.server)
                            .font(.caption)

                        if let job = character.job, !job.isEmpty {
                            Text("•")
                                .font(.caption2)
                            Text(job)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.secondary)

                    Text("\(character.completedNodeIds.count) completed")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct FeatureIdeaView: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
