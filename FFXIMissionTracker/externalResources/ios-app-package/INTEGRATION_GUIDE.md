# iOS App Integration Guide

## 📦 Package Contents

This package contains clean, production-ready FFXI mission data for iOS app integration.

### Files Included

```
ios-app-package/
├── api-response.json              # Single consolidated API with all mission sets
├── ffxiclopedia-bastok.json       # Bastok missions (20 missions, 95 nodes)
├── ffxiclopedia-sandoria.json     # San d'Oria missions (14 missions, 77 nodes)
├── ffxiclopedia-windurst.json     # Windurst missions (15 missions, 61 nodes)
├── zilart.json                    # Rise of the Zilart (15 missions, 41 nodes)
├── promathia.json                 # Chains of Promathia (23 missions, 71 nodes)
├── Models.swift                   # Swift model definitions
└── INTEGRATION_GUIDE.md           # This file
```

### Total Data
- **5 mission sets**
- **87 missions**
- **345 nodes**
- **0 HTML artifacts**
- **100% schema validated**

---

## 🚀 Quick Start

### Option 1: Use Single API File (Recommended)

Load all mission data from one file:

```swift
import Foundation

// 1. Add api-response.json to your Xcode project
// 2. Load the data
func loadMissions() throws -> MissionAPIResponse {
    guard let url = Bundle.main.url(forResource: "api-response", withExtension: "json") else {
        throw MissionError.fileNotFound
    }

    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try decoder.decode(MissionAPIResponse.self, from: data)
}

// 3. Use the data
let apiResponse = try loadMissions()
print("Loaded \(apiResponse.stats.totalMissions) missions")
```

### Option 2: Load Individual Mission Sets

For better performance, load only the mission sets you need:

```swift
func loadBastokMissions() throws -> MissionSet {
    guard let url = Bundle.main.url(forResource: "ffxiclopedia-bastok", withExtension: "json") else {
        throw MissionError.fileNotFound
    }

    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try decoder.decode(MissionSet.self, from: data)
}
```

---

## 📱 SwiftUI Example

### Simple Mission List

```swift
import SwiftUI

struct MissionListView: View {
    let missionSet: MissionSet

    var body: some View {
        List(missionSet.missions) { mission in
            NavigationLink(destination: MissionDetailView(mission: mission)) {
                MissionRowView(mission: mission)
            }
        }
        .navigationTitle(missionSet.name)
    }
}

struct MissionRowView: View {
    let mission: Mission

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let number = mission.number {
                    Text(number)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }

                Text(mission.title)
                    .font(.headline)
            }

            Text("\(mission.nodes.count) steps")
                .font(.caption)
                .foregroundColor(.secondary)

            if let zones = mission.zones.first {
                Label(zones, systemImage: "map")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
```

### Mission Detail with Node Steps

```swift
struct MissionDetailView: View {
    let mission: Mission
    @State private var completedNodes: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    if let number = mission.number {
                        Text("Mission \(number)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(mission.title)
                        .font(.title)
                        .bold()

                    // Zones
                    if !mission.zones.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(mission.zones, id: \.self) { zone in
                                    Label(zone, systemImage: "map")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
                .padding()

                Divider()

                // Node Steps
                ForEach(mission.nodes) { node in
                    NodeStepView(
                        node: node,
                        isCompleted: completedNodes.contains(node.id),
                        canStart: node.canStart(completedNodeIds: completedNodes)
                    ) {
                        toggleNodeCompletion(node.id)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleNodeCompletion(_ nodeId: String) {
        if completedNodes.contains(nodeId) {
            completedNodes.remove(nodeId)
        } else {
            completedNodes.insert(nodeId)
        }
    }
}

struct NodeStepView: View {
    let node: MissionNode
    let isCompleted: Bool
    let canStart: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Checkbox
                Button(action: onToggle) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : .gray)
                        .font(.title2)
                }
                .disabled(!canStart && !isCompleted)

                VStack(alignment: .leading, spacing: 6) {
                    // Step number
                    Text("Step \(node.orderIndex + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Title
                    Text(node.title)
                        .font(.headline)

                    // Description
                    Text(node.description)
                        .font(.body)
                        .foregroundColor(.secondary)

                    // Location info
                    if let location = node.location {
                        HStack(spacing: 4) {
                            if let zone = location.zone {
                                Label(zone, systemImage: "map")
                                    .font(.caption)
                            }

                            if let coords = location.coordinates {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text(coords)
                                    .font(.caption.monospaced())
                            }

                            if let npc = location.npc {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Label(npc, systemImage: "person")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCompleted ? Color.green : Color.clear, lineWidth: 2)
            )
            .opacity(canStart || isCompleted ? 1.0 : 0.5)
        }
        .padding(.horizontal)
    }
}
```

---

## 🔍 Common Use Cases

### 1. Search Missions by Zone

```swift
func searchMissions(inZone zone: String, from apiResponse: MissionAPIResponse) -> [Mission] {
    apiResponse.missionSets.flatMap { set in
        set.missions(inZone: zone)
    }
}

// Usage
let bastokMinesMissions = searchMissions(inZone: "Bastok Mines", from: apiResponse)
```

### 2. Filter Missions by Level

```swift
func missions(forLevel level: Int, from apiResponse: MissionAPIResponse) -> [Mission] {
    apiResponse.missionSets.flatMap { set in
        set.missions.filter { mission in
            guard let minLevel = mission.metadata?.minLevel else { return true }
            return minLevel <= level
        }
    }
}
```

### 3. Track Mission Progress

```swift
class MissionProgressTracker: ObservableObject {
    @Published private(set) var completedNodes: Set<String> = []

    func completeNode(_ nodeId: String) {
        completedNodes.insert(nodeId)
        saveProgress()
    }

    func isCompleted(_ nodeId: String) -> Bool {
        completedNodes.contains(nodeId)
    }

    func isMissionCompleted(_ mission: Mission) -> Bool {
        mission.nodes.allSatisfy { completedNodes.contains($0.id) }
    }

    func availableNodes(in mission: Mission) -> [MissionNode] {
        mission.nodes.filter { $0.canStart(completedNodeIds: completedNodes) }
    }

    private func saveProgress() {
        UserDefaults.standard.set(Array(completedNodes), forKey: "completedMissionNodes")
    }
}
```

### 4. Build Mission Dependency Graph

```swift
func buildDependencyGraph(for mission: Mission) -> [String: [String]] {
    var graph: [String: [String]] = [:]

    for node in mission.nodes {
        graph[node.id] = mission.dependentNodes(of: node.id).map { $0.id }
    }

    return graph
}
```

---

## 📊 Data Structure Reference

### Location Object
```json
{
  "coordinates": "D-7",        // Grid coordinates (optional)
  "zone": "Bastok Mines",      // Zone/area name (optional)
  "npc": "Makarim"             // NPC name (optional)
}
```

**Usage Notes:**
- `coordinates`: Format is always "X-Y" (e.g., "H-9", "D-7")
- `zone`: Full zone name as it appears in-game
- `npc`: NPC name when the node involves talking to an NPC
- All fields are optional and may be `null`

### Mission Node Structure
```json
{
  "id": "bastok-rank-the-zeruhn-report-node-2",
  "orderIndex": 1,
  "title": "(Bastok Mines) Go to (D-7) and enter Zeruhn Mines.",
  "description": "(Bastok Mines) Go to (D-7) and enter Zeruhn Mines.",
  "dependencies": ["bastok-rank-the-zeruhn-report-node-1"],
  "location": { /* Location object */ }
}
```

**Usage Notes:**
- `orderIndex`: Sequential index for display order (0-based)
- `dependencies`: Array of node IDs that must be completed first
- `title`: Concise step description (max ~150 chars)
- `description`: Full step description (1-2 sentences)

---

## ⚠️ Important Notes

### Data Quality
✅ **HTML-free**: All HTML tags, image captions, and artifacts removed
✅ **Clean text**: Descriptions are 1-2 sentences, no navigation warnings
✅ **Structured locations**: Coordinates, zones, NPCs in separate fields
✅ **Schema validated**: All data passes JSON schema validation

### Limitations
- **7 mission sets not included**: Some expansions (ToAU, WotG, SoA, RoV) and addons are not in this package because their URLs are not configured
- **1 missing mission**: Windurst has 16/17 missions (missing "The Jester Who'd Be King" due to HTML download issue)
- **Location data coverage**: ~75% of nodes have location data (some steps don't involve specific locations)

### Performance Tips
1. **Load incrementally**: Load mission sets on-demand rather than all at once
2. **Cache decoded data**: Decode JSON once and keep in memory
3. **Index by ID**: Build lookup dictionaries for O(1) access
4. **Filter early**: Filter missions before displaying to reduce UI overhead

---

## 🔧 Troubleshooting

### "File not found" error
Ensure JSON files are added to your Xcode project target (check Target Membership in File Inspector)

### Decoding errors
Check that you're using the correct model file (`Models.swift`) and that Swift types match the JSON structure

### Missing location data
Not all mission nodes have location data - always check for `nil` before accessing location properties

### Performance issues
If loading all missions is slow, consider:
- Loading mission sets individually
- Implementing pagination for mission lists
- Using background threads for JSON decoding

---

## 📚 Next Steps

1. **Add to Xcode**: Drag JSON files into your project
2. **Copy Models.swift**: Add the Swift model definitions
3. **Test loading**: Try the Quick Start example
4. **Build UI**: Use the SwiftUI examples as a starting point
5. **Track progress**: Implement the progress tracker
6. **Customize**: Adapt the UI to your app's design

For questions or issues, refer to:
- [PARSER_IMPROVEMENTS.md](../PARSER_IMPROVEMENTS.md) - Technical parser details
- [RE-SCRAPE_SUMMARY.md](../RE-SCRAPE_SUMMARY.md) - Data generation summary
- [BEFORE_AFTER_COMPARISON.md](../BEFORE_AFTER_COMPARISON.md) - Data quality examples
