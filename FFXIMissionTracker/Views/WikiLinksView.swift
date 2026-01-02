//
//  WikiLinksView.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 12/30/25.
//

import SwiftUI

struct WikiLinksView: View {
    let missionSets: [MissionSet]
    let questSets: [MissionSet]

    @State private var selectedCategory: ContentCategory = .missions
    @State private var searchText = ""

    enum ContentCategory: String, CaseIterable {
        case missions = "Missions"
        case quests = "Quests"
    }

    private var filteredSets: [MissionSet] {
        let sets = selectedCategory == .missions ? missionSets : questSets

        if searchText.isEmpty {
            return sets
        }

        return sets.compactMap { set in
            let filteredMissions = set.missions.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }

            if filteredMissions.isEmpty {
                return nil
            }

            return MissionSet(
                id: set.id,
                name: set.name,
                category: set.category,
                source: set.source,
                sourceUrl: set.sourceUrl,
                lastScraped: set.lastScraped,
                lastKnownUpdate: set.lastKnownUpdate,
                totalMissions: filteredMissions.count,
                missions: filteredMissions
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search and filter
            VStack(spacing: 12) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search missions or quests...", text: $searchText)
                        .textFieldStyle(.plain)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)

                // Category picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(ContentCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()

            Divider()

            // Wiki links organized by set
            if filteredSets.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "link")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)

                    Text(searchText.isEmpty ? "No links available" : "No results found")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredSets) { set in
                        Section {
                            ForEach(set.missions) { mission in
                                WikiLinkRow(
                                    mission: mission,
                                    isMission: selectedCategory == .missions
                                )
                            }
                        } header: {
                            Text(set.name)
                        }
                    }
                }
                #if os(iOS)
                .listStyle(.insetGrouped)
                #endif
            }
        }
        .navigationTitle("Wiki Links")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct WikiLinkRow: View {
    let mission: Mission
    let isMission: Bool

    var body: some View {
        if let urlString = mission.url, let url = URL(string: urlString) {
            Link(destination: url) {
                HStack(spacing: 12) {
                    // Icon
                    Image(systemName: isMission ? "flag.fill" : "star.fill")
                        .foregroundColor(isMission ? .purple : .orange)
                        .frame(width: 24)

                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        // Title
                        Text(mission.title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        // Mission number
                        if let number = mission.number {
                            Text(number)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // Zones if available
                        if !mission.zones.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "map")
                                    .font(.caption2)
                                Text(mission.zones.prefix(2).joined(separator: ", "))
                                    .font(.caption)
                                if mission.zones.count > 2 {
                                    Text("+ \(mission.zones.count - 2) more")
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(.blue)
                        }
                    }

                    Spacer()

                    // Link indicator
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
        } else {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.title)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    if let number = mission.number {
                        Text(number)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("No wiki link available")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        WikiLinksView(
            missionSets: [],
            questSets: []
        )
    }
}
