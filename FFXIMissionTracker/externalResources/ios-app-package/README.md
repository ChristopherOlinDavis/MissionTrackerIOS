# FFXI Mission Data Package for iOS

**Production-ready mission data for Final Fantasy XI iOS app development**

## 📦 What's Inside

Clean, structured mission data with:
- ✅ **0 HTML artifacts** - Pure text content
- ✅ **Structured locations** - Coordinates, zones, and NPCs in separate fields
- ✅ **Smart descriptions** - Concise 1-2 sentence summaries
- ✅ **100% validated** - Schema-validated JSON

## 📊 Data Stats

| Mission Set | Missions | Nodes | Status |
|------------|----------|-------|--------|
| Bastok Missions | 20 | 95 | ✅ Complete |
| San d'Oria Missions | 14 | 77 | ✅ Complete |
| Windurst Missions | 15 | 61 | ✅ Complete |
| Rise of the Zilart | 15 | 41 | ✅ Complete |
| Chains of Promathia | 23 | 71 | ✅ Complete |
| **TOTAL** | **87** | **345** | **✅** |

## 🚀 Quick Start

### 1. Add Files to Xcode
Drag these files into your Xcode project:
- `api-response.json` (all missions in one file)
- `Models.swift` (Swift type definitions)

### 2. Load the Data
```swift
import Foundation

func loadMissions() throws -> MissionAPIResponse {
    guard let url = Bundle.main.url(forResource: "api-response", withExtension: "json") else {
        throw NSError(domain: "MissionLoader", code: 404)
    }

    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(MissionAPIResponse.self, from: data)
}

// Usage
let missions = try loadMissions()
print("Loaded \(missions.stats.totalMissions) missions!")
```

### 3. Build Your UI
See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for complete SwiftUI examples.

## 📁 Files

```
ios-app-package/
├── api-response.json              # All missions (recommended)
├── ffxiclopedia-bastok.json       # Bastok missions only
├── ffxiclopedia-sandoria.json     # San d'Oria missions only
├── ffxiclopedia-windurst.json     # Windurst missions only
├── zilart.json                    # Zilart missions only
├── promathia.json                 # Promathia missions only
├── Models.swift                   # Swift models
├── INTEGRATION_GUIDE.md           # Full integration guide
└── README.md                      # This file
```

## 💡 Example: Display Mission List

```swift
import SwiftUI

struct MissionListView: View {
    let missions: [Mission]

    var body: some View {
        List(missions) { mission in
            VStack(alignment: .leading) {
                HStack {
                    if let number = mission.number {
                        Text(number)
                            .font(.caption)
                            .padding(4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    Text(mission.title)
                        .font(.headline)
                }

                Text("\(mission.nodes.count) steps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

## 🎯 Key Features

### Clean Data Structure
Every mission node includes:
```json
{
  "id": "unique-node-id",
  "title": "Clear action description",
  "description": "1-2 sentence summary",
  "location": {
    "zone": "Bastok Mines",
    "coordinates": "D-7",
    "npc": "Guard Name"
  }
}
```

### Dependency Tracking
Nodes have dependencies for proper sequencing:
```swift
node.dependencies // IDs of nodes that must be completed first
node.canStart(completedNodeIds: completedSet) // Check if ready
```

### Location Search
Filter missions by zone, coordinates, or NPC:
```swift
missions.filter { mission in
    mission.nodes.contains {
        $0.location?.zone == "Bastok Mines"
    }
}
```

## 📖 Documentation

- **[INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)** - Complete integration guide with SwiftUI examples
- **[Models.swift](Models.swift)** - Swift model definitions with helper methods
- **Parent repo docs:**
  - [PARSER_IMPROVEMENTS.md](../PARSER_IMPROVEMENTS.md) - Data quality improvements
  - [RE-SCRAPE_SUMMARY.md](../RE-SCRAPE_SUMMARY.md) - Generation summary

## 🔍 Data Quality

### Before Improvements
```json
{
  "title": "(Bas.",  // ❌ Truncated
  "description": "<img alt='...'> Some text"  // ❌ HTML
}
```

### After Improvements
```json
{
  "title": "(Bastok Mines) Go to (D-7) and enter Zeruhn Mines.",
  "description": "(Bastok Mines) Go to (D-7) and enter Zeruhn Mines.",
  "location": {
    "zone": "Bastok Mines",
    "coordinates": "D-7"
  }
}
```

## ⚙️ Technical Details

- **Format:** JSON (UTF-8)
- **Size:** ~2.5MB total (api-response.json is ~2MB)
- **Encoding:** Standard JSON, compatible with Swift Codable
- **Validation:** All files pass JSON schema validation
- **Generation:** Scraped from FFXIclopedia wiki, cleaned and structured

## 📝 License

Mission data sourced from FFXIclopedia (Fandom Wiki).
Parser and data package created for educational/reference purposes.

## 🆘 Support

For issues or questions:
1. Check [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for common solutions
2. Review the Swift model definitions in [Models.swift](Models.swift)
3. See parent repo documentation for parser details

---

**Ready to build?** Start with [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)!
