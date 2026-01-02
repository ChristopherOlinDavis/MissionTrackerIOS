//
//  ExportImportView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/30/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportImportView: View {
    @Bindable var characterManager: CharacterManager
    @Binding var progressTracker: MissionProgressTracker
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var exportData: Data?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""

    var body: some View {
        Form {
            // Export Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Export Character Data", systemImage: "square.and.arrow.up.fill")
                        .font(.headline)

                    Text("Create a backup of your character progress that can be saved or shared.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let character = characterManager.activeCharacter {
                        HStack {
                            Text("Character:")
                                .foregroundColor(.secondary)
                            Text(character.name)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(character.completedNodeIds.count) nodes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    Button {
                        exportCharacterData()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Current Character")
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(characterManager.activeCharacter == nil)

                    Button {
                        exportAllCharacters()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "person.3.fill")
                            Text("Export All Characters")
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .disabled(characterManager.characters.isEmpty)
                }
                .padding(.vertical, 8)
            } header: {
                Text("Export")
            }

            // Import Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Import Character Data", systemImage: "square.and.arrow.down.fill")
                        .font(.headline)

                    Text("Restore character progress from a previously exported backup file.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button {
                        showingImportSheet = true
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.down")
                            Text("Import Character Data")
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding(.vertical, 8)
            } header: {
                Text("Import")
            } footer: {
                Text("Importing will merge with existing characters. Characters with the same name will be updated.")
                    .font(.caption)
            }

            // Info Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(icon: "checkmark.circle.fill", text: "Progress is saved per character", color: .green)
                    InfoRow(icon: "icloud.fill", text: "Files can be shared via AirDrop, email, or cloud storage", color: .blue)
                    InfoRow(icon: "lock.fill", text: "Your data stays private and local", color: .orange)
                }
            } header: {
                Text("About Export/Import")
            }
        }
        .navigationTitle("Export/Import")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        #if os(iOS)
        .sheet(isPresented: $showingExportSheet) {
            if let data = exportData {
                ShareSheet(items: [data])
            }
        }
        #endif
        .fileImporter(
            isPresented: $showingImportSheet,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result: result)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func exportCharacterData() {
        guard let character = characterManager.activeCharacter else { return }

        let exportModel = CharacterExportModel(
            version: "1.0",
            exportDate: Date(),
            characters: [character]
        )

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(exportModel)

            exportData = data
            showingExportSheet = true
        } catch {
            alertTitle = "Export Failed"
            alertMessage = "Failed to export character data: \(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func exportAllCharacters() {
        let exportModel = CharacterExportModel(
            version: "1.0",
            exportDate: Date(),
            characters: characterManager.characters
        )

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(exportModel)

            exportData = data
            showingExportSheet = true
        } catch {
            alertTitle = "Export Failed"
            alertMessage = "Failed to export character data: \(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let importModel = try decoder.decode(CharacterExportModel.self, from: data)

                // Merge characters
                var importedCount = 0
                var updatedCount = 0

                for importedCharacter in importModel.characters {
                    if let existingIndex = characterManager.characters.firstIndex(where: { $0.id == importedCharacter.id }) {
                        // Update existing character
                        characterManager.characters[existingIndex] = importedCharacter
                        updatedCount += 1
                    } else if characterManager.canAddMoreCharacters {
                        // Add new character
                        characterManager.characters.append(importedCharacter)
                        importedCount += 1
                    }
                }

                // Refresh progress tracker
                progressTracker.refreshProgress()

                alertTitle = "Import Successful"
                if importedCount > 0 && updatedCount > 0 {
                    alertMessage = "Imported \(importedCount) new character(s) and updated \(updatedCount) existing character(s)."
                } else if importedCount > 0 {
                    alertMessage = "Imported \(importedCount) character(s) successfully."
                } else if updatedCount > 0 {
                    alertMessage = "Updated \(updatedCount) character(s) successfully."
                } else {
                    alertMessage = "No characters were imported. You may have reached the character limit."
                }
                showingAlert = true

            } catch {
                alertTitle = "Import Failed"
                alertMessage = "Failed to import character data: \(error.localizedDescription)"
                showingAlert = true
            }

        case .failure(let error):
            alertTitle = "Import Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(text)
                .font(.caption)
        }
    }
}

// Share sheet for iOS
#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

// Export data model
struct CharacterExportModel: Codable {
    let version: String
    let exportDate: Date
    let characters: [Character]
}

#Preview {
    NavigationStack {
        ExportImportView(
            characterManager: CharacterManager(),
            progressTracker: .constant(MissionProgressTracker(characterManager: CharacterManager()))
        )
    }
}
