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

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("FINAL FANTASY XI")
                    .font(.caption)
                    .fontWeight(.semibold)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            .foregroundColor(.primary)

            // Character Switcher
            if let characterManager = characterManager,
               let activeCharacter = characterManager.activeCharacter {
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
                        Image(systemName: "person.circle.fill")
                            .font(.caption2)
                        Text(activeCharacter.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.1))
    }
}

#Preview {
    HeaderView()
}
