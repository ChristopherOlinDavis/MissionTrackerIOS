//
//  UnityNMsTabView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/31/25.
//

import SwiftUI

struct UnityNMsTabView: View {
    @Binding var progressTracker: MissionProgressTracker
    @State private var unmLoader = UnityNMDataLoader()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HeaderView(
                    characterManager: progressTracker.characterManager,
                    onCharacterChange: { progressTracker.refreshProgress() }
                )

                // Content
                if unmLoader.isLoading {
                    VStack(spacing: 20) {
                        Spacer()
                        ProgressView()
                        Text("Loading Unity NMs...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                } else if let error = unmLoader.error {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 72))
                            .foregroundStyle(.orange)
                        Text("Error Loading Data")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                } else {
                    UNMCategoryListView(
                        unmLoader: unmLoader,
                        progressTracker: progressTracker
                    )
                }

                // Footer
                FooterView()
            }
            .navigationTitle("Unity NMs")
        }
    }
}

#Preview {
    UnityNMsTabView(
        progressTracker: .constant(MissionProgressTracker(characterManager: CharacterManager()))
    )
}
