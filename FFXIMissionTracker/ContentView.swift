//
//  ContentView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/29/25.
//

import SwiftUI

struct ContentView: View {
    @State private var characterManager = CharacterManager()
    @State private var progressTracker: MissionProgressTracker
    @State private var selectedTab = 0

    init() {
        let charManager = CharacterManager()
        _characterManager = State(initialValue: charManager)
        _progressTracker = State(initialValue: MissionProgressTracker(characterManager: charManager))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            MissionsTabView(progressTracker: $progressTracker)
                .tabItem {
                    Label("Missions", systemImage: "list.bullet.clipboard")
                }
                .tag(0)

            QuestsTabView(progressTracker: $progressTracker)
                .tabItem {
                    Label("Quests", systemImage: "book")
                }
                .tag(1)

            UnityNMsTabView(progressTracker: $progressTracker)
                .tabItem {
                    Label("Unity NMs", systemImage: "flag.2.crossed")
                }
                .tag(2)

            ROETabView(progressTracker: $progressTracker)
                .tabItem {
                    Label("Records", systemImage: "trophy")
                }
                .tag(3)

            SettingsTabView(
                characterManager: characterManager,
                progressTracker: $progressTracker
            )
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
}
