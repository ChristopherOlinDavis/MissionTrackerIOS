//
//  HeaderView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import SwiftUI

struct HeaderView: View {
    var characterManager: CharacterManager? = nil
    var onCharacterChange: (() -> Void)? = nil

    @State private var showingAddCharacter = false
    @State private var newCharacterName = ""

    var body: some View {
        VStack(spacing: 6) {
            // App Title
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)

                Text("FINAL FANTASY XI")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(1.2)

                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
            }
            .foregroundStyle(.primary)

            Text("Vana'diel Progress Tracker")
                .font(.caption2)
                .foregroundStyle(.secondary)

            // Character Switcher with Add Button
            if let characterManager = characterManager,
               let activeCharacter = characterManager.activeCharacter {
                Divider()
                    .padding(.vertical, 2)

                HStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)

                    Menu {
                        ForEach(characterManager.characters) { character in
                            Button {
                                characterManager.setActiveCharacter(id: character.id)
                                onCharacterChange?()
                            } label: {
                                HStack {
                                    Text(character.displayName)
                                    if character.id == activeCharacter.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(activeCharacter.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.blue)
                    }

                    // Add Character Button
                    if characterManager.canAddMoreCharacters {
                        Button {
                            showingAddCharacter = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.secondary.opacity(0.08),
                    Color.secondary.opacity(0.12)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(isPresented: $showingAddCharacter) {
            AddCharacterSheet(
                characterManager: characterManager,
                onCharacterAdded: {
                    onCharacterChange?()
                }
            )
        }
    }
}

struct AddCharacterSheet: View {
    let characterManager: CharacterManager?
    let onCharacterAdded: () -> Void

    @State private var characterName = ""
    @State private var serverName = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Character Name", text: $characterName)
                        #if os(iOS)
                        .textInputAutocapitalization(.words)
                        #endif

                    TextField("Server", text: $serverName)
                        #if os(iOS)
                        .textInputAutocapitalization(.words)
                        #endif
                } header: {
                    Text("New Character")
                } footer: {
                    if let manager = characterManager {
                        Text("\(manager.characters.count)/\(manager.characterLimit) characters")
                            .font(.caption)
                    }
                }

                Section {
                    Button {
                        if let manager = characterManager,
                           !characterName.trimmingCharacters(in: .whitespaces).isEmpty,
                           !serverName.trimmingCharacters(in: .whitespaces).isEmpty {
                            _ = manager.addCharacter(name: characterName, server: serverName)
                            onCharacterAdded()
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Create Character")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .disabled(characterName.trimmingCharacters(in: .whitespaces).isEmpty ||
                             serverName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Add Character")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HeaderView()
}
