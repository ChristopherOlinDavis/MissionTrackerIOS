# FFXI Mission Tracker - iOS App

A native iOS app for tracking Final Fantasy XI mission progress with a beautiful, intuitive interface.

## Features

- **Browse Mission Sets**: View all available mission sets (Bastok, San d'Oria, Windurst, Zilart, Promathia)
- **Mission Details**: See step-by-step walkthroughs for each mission
- **Progress Tracking**: Check off completed mission nodes and track overall progress
- **Node Dependencies**: Visual indicators show which steps are available based on dependencies
- **Location Information**: Coordinates, zones, and NPC names displayed for each step
- **Persistent Progress**: Your progress is automatically saved using UserDefaults
- **Clean UI**: Native SwiftUI interface with smooth animations

## Project Structure

```
FFXIMissionTracker/
├── Models/
│   └── MissionModels.swift          # Data models for missions, nodes, gates
├── Services/
│   ├── MissionDataLoader.swift      # JSON data loading service
│   └── MissionProgressTracker.swift # Progress tracking with persistence
├── Views/
│   ├── MissionSetListView.swift     # List of mission sets
│   ├── MissionListView.swift        # List of missions in a set
│   └── MissionDetailView.swift      # Mission details with node steps
├── Resources/
│   ├── api-response.json            # All missions (not used currently)
│   ├── ffxiclopedia-bastok.json     # Bastok missions
│   ├── ffxiclopedia-sandoria.json   # San d'Oria missions
│   ├── ffxiclopedia-windurst.json   # Windurst missions
│   ├── zilart.json                  # Rise of the Zilart
│   └── promathia.json               # Chains of Promathia
├── ContentView.swift                # Main app view
└── FFXIMissionTrackerApp.swift      # App entry point
```

## Data Model

### MissionSet
Represents a collection of missions (e.g., Bastok Rank Missions)
- `id`: Unique identifier
- `name`: Display name
- `missions`: Array of missions

### Mission
Individual mission with multiple steps
- `id`: Unique identifier
- `title`: Mission name
- `number`: Mission number (e.g., "1-1")
- `nodes`: Array of mission nodes (steps)
- `gates`: Array of requirements/blockers

### MissionNode
Individual step in a mission
- `id`: Unique identifier
- `orderIndex`: Step number (0-based)
- `title`: Step title
- `description`: Detailed description
- `dependencies`: Array of node IDs that must be completed first
- `location`: Optional location information (zone, coordinates, NPC)

### Gate
Requirements or blockers between mission steps
- `type`: Gate type (level, mission, item, etc.)
- `requirement`: Brief requirement description
- `description`: Detailed explanation

## Building the App

### Requirements
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Steps

1. **Open the project**
   ```bash
   open FFXIMissionTracker.xcodeproj
   ```

2. **Add JSON files to Xcode target**
   - The JSON files are already in `FFXIMissionTracker/Resources/`
   - In Xcode, select each JSON file
   - In the File Inspector (right sidebar), check the box next to your target under "Target Membership"

3. **Build and run**
   - Select your device or simulator
   - Press `Cmd+R` to build and run

## Usage

### Browsing Missions
1. Launch the app to see all mission sets
2. Tap a mission set to view its missions
3. Tap a mission to see detailed steps

### Tracking Progress
1. In mission detail view, tap the circle next to each step to mark it complete
2. Steps with dependencies will be grayed out until prerequisites are met
3. Completed steps show a green checkmark
4. Progress bars show completion percentage

### Resetting Progress
1. Tap the menu button (⋯) in the top-right
2. Select "Reset All Progress"
3. Confirm to clear all tracked progress

## Data Source

Mission data is sourced from FFXIclopedia and pre-processed by a Python scraper. The data includes:
- 5 mission sets
- 87 missions
- 345+ mission nodes
- Clean, structured JSON with no HTML artifacts

Data is stored in the `externalResources/` directory and copied into the app bundle.

## Future Enhancements

Potential improvements:
- [ ] Search functionality to find missions by zone or NPC
- [ ] Filter missions by completion status
- [ ] Export/import progress
- [ ] iCloud sync for cross-device progress
- [ ] Dark mode optimization
- [ ] Node graph visualization (visual tree/flowchart)
- [ ] Notification reminders for incomplete missions
- [ ] Add remaining mission sets (ToAU, WotG, SoA, RoV)

## Development Notes

### Adding New Mission Data
1. Place JSON files in `FFXIMissionTracker/Resources/`
2. Add filename to `loadAllMissionSets()` in `MissionDataLoader.swift`
3. Ensure files follow the data model schema

### Modifying Progress Tracking
Progress is stored in UserDefaults with the key `"completedMissionNodes"` as an array of node IDs. To customize storage:
- Edit `MissionProgressTracker.swift`
- Modify `saveProgress()` and `loadProgress()` methods

## License

Mission data sourced from FFXIclopedia (Fandom Wiki).
App created for educational and reference purposes.

## Contributing

This is a personal project, but suggestions and bug reports are welcome through GitHub issues.
