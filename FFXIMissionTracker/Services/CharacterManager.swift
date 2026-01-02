//
//  CharacterManager.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/30/25.
//

import Foundation
import SwiftUI

@Observable
class CharacterManager {
    private let maxCharacters = 18
    private let charactersKey = "characters"
    private let activeCharacterIdKey = "activeCharacterId"

    var characters: [Character] = []
    var activeCharacter: Character?

    init() {
        loadCharacters()
        migrateFromSingleCharacterIfNeeded()
    }

    // MARK: - Character Management

    func addCharacter(name: String, server: String, job: String? = nil) -> Character? {
        guard characters.count < maxCharacters else { return nil }
        guard !name.isEmpty && !server.isEmpty else { return nil }

        let character = Character(name: name, server: server, job: job)
        characters.append(character)

        // If this is the first character, make it active
        if activeCharacter == nil {
            activeCharacter = character
        }

        saveCharacters()
        return character
    }

    func updateCharacter(_ character: Character) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index] = character

            // Update active character if it's the one being updated
            if activeCharacter?.id == character.id {
                activeCharacter = character
            }

            saveCharacters()
        }
    }

    func deleteCharacter(id: UUID) {
        characters.removeAll { $0.id == id }

        // If we deleted the active character, switch to first available
        if activeCharacter?.id == id {
            activeCharacter = characters.first
        }

        saveCharacters()
    }

    func setActiveCharacter(id: UUID) {
        if let character = characters.first(where: { $0.id == id }) {
            activeCharacter = character
            UserDefaults.standard.set(id.uuidString, forKey: activeCharacterIdKey)
        }
    }

    // MARK: - Progress Management

    func getProgress(for characterId: UUID) -> Set<String> {
        characters.first(where: { $0.id == characterId })?.completedNodeIds ?? []
    }

    func saveProgress(nodeIds: Set<String>, for characterId: UUID) {
        if let index = characters.firstIndex(where: { $0.id == characterId }) {
            characters[index].completedNodeIds = nodeIds

            // Update active character if it's the one being updated
            if activeCharacter?.id == characterId {
                activeCharacter = characters[index]
            }

            saveCharacters()
        }
    }

    // Enhanced progress data management
    func saveProgressData(_ progressData: ProgressData, for characterId: UUID) {
        if let index = characters.firstIndex(where: { $0.id == characterId }) {
            characters[index].progress = progressData

            // Update active character if it's the one being updated
            if activeCharacter?.id == characterId {
                activeCharacter = characters[index]
            }

            saveCharacters()
        }
    }

    func getProgressData(for characterId: UUID) -> ProgressData? {
        characters.first(where: { $0.id == characterId })?.progress
    }

    // MARK: - Persistence

    private func saveCharacters() {
        if let encoded = try? JSONEncoder().encode(characters) {
            UserDefaults.standard.set(encoded, forKey: charactersKey)
        }

        if let activeId = activeCharacter?.id {
            UserDefaults.standard.set(activeId.uuidString, forKey: activeCharacterIdKey)
        }
    }

    private func loadCharacters() {
        if let data = UserDefaults.standard.data(forKey: charactersKey),
           let decoded = try? JSONDecoder().decode([Character].self, from: data) {
            characters = decoded

            // Load active character
            if let activeIdString = UserDefaults.standard.string(forKey: activeCharacterIdKey),
               let activeId = UUID(uuidString: activeIdString) {
                activeCharacter = characters.first(where: { $0.id == activeId })
            }

            // Fallback to first character if no active one
            if activeCharacter == nil {
                activeCharacter = characters.first
            }
        }
    }

    // MARK: - Migration

    private func migrateFromSingleCharacterIfNeeded() {
        // Check if we have old single-character data
        if characters.isEmpty,
           let oldProgress = UserDefaults.standard.stringArray(forKey: "completedNodeIds") {

            print("📦 Migrating from single character to multi-character system...")

            // Create default character with existing progress
            let defaultCharacter = Character(
                name: "Character 1",
                server: "Unknown",
                job: nil,
                createdDate: Date(),
                completedNodeIds: Set(oldProgress)
            )

            characters = [defaultCharacter]
            activeCharacter = defaultCharacter

            saveCharacters()

            // Remove old key
            UserDefaults.standard.removeObject(forKey: "completedNodeIds")

            print("✅ Migration complete! Created default character with \(oldProgress.count) completed nodes")
        }
    }

    // MARK: - Utility

    var canAddMoreCharacters: Bool {
        characters.count < maxCharacters
    }

    var characterLimit: Int {
        maxCharacters
    }
}
