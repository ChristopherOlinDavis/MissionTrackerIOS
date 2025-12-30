//
//  AddCharacterView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/30/25.
//

import SwiftUI

struct AddCharacterView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var characterManager: CharacterManager

    @State private var name = ""
    @State private var server = ""
    @State private var job = ""

    private let servers = [
        "Asura", "Bahamut", "Bismarck", "Carbuncle", "Cerberus",
        "Fenrir", "Lakshmi", "Leviathan", "Odin", "Phoenix",
        "Quetzalcoatl", "Ragnarok", "Shiva", "Siren", "Valefor"
    ].sorted()

    private let jobs = [
        "WAR", "MNK", "WHM", "BLM", "RDM", "THF",
        "PLD", "DRK", "BST", "BRD", "RNG", "SAM",
        "NIN", "DRG", "SMN", "BLU", "COR", "PUP",
        "DNC", "SCH", "GEO", "RUN"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Character Details") {
                    TextField("Character Name", text: $name)
                        #if os(iOS)
                        .textInputAutocapitalization(.words)
                        #endif

                    Picker("Server", selection: $server) {
                        Text("Select Server").tag("")
                        ForEach(servers, id: \.self) { server in
                            Text(server).tag(server)
                        }
                    }

                    Picker("Main Job (Optional)", selection: $job) {
                        Text("None").tag("")
                        ForEach(jobs, id: \.self) { job in
                            Text(job).tag(job)
                        }
                    }
                }

                Section {
                    Text("You can track up to \(characterManager.characterLimit) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
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

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let newCharacter = characterManager.addCharacter(
                            name: name,
                            server: server,
                            job: job.isEmpty ? nil : job
                        ) {
                            dismiss()
                        }
                    }
                    .disabled(!canAdd)
                }
            }
        }
    }

    private var canAdd: Bool {
        !name.isEmpty && !server.isEmpty
    }
}

#Preview {
    AddCharacterView(characterManager: CharacterManager())
}
