//
//  ROETabView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/31/25.
//

import SwiftUI

struct ROETabView: View {
    @Binding var progressTracker: MissionProgressTracker
    @State private var roeLoader = ROEDataLoader()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HeaderView(
                    characterManager: progressTracker.characterManager,
                    onCharacterChange: { progressTracker.refreshProgress() }
                )

                // Content
                if roeLoader.isLoading {
                    VStack(spacing: 20) {
                        Spacer()
                        ProgressView()
                        Text("Loading ROE Objectives...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                } else if let error = roeLoader.error {
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
                    ROECategoryListView(
                        roeLoader: roeLoader,
                        progressTracker: progressTracker
                    )
                }

                // Footer
                FooterView()
            }
            .navigationTitle("Records of Eminence")
        }
    }
}

#Preview {
    ROETabView(
        progressTracker: .constant(MissionProgressTracker(characterManager: CharacterManager()))
    )
}
