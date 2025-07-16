# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

IWNDWYT (I Will Not Drink With You Today) is a native iOS habit tracking app built with SwiftUI. The app helps users track streaks, celebrate milestones, and receive motivational notifications to maintain their positive habit streaks.

## Architecture

### Core Components
- **Models**: Data models and business logic (`StreakData`, `Streak`, `MotivationManager`, `DateProvider`)
- **ViewModels**: Reactive state management (`DayCounterViewModel`, `AppSettingsViewModel`, `SessionTracker`)
- **Views**: SwiftUI interface components with tab-based navigation via `MainTabView`

### Key Features
- Streak tracking with milestone celebrations
- Calendar view showing streak history with color coding
- Daily motivational notifications
- Metrics and analytics
- Debug panel for development (debug builds only)
- Tip jar integration with StoreKit
- Screenshot data generator for App Store materials

### State Management
The app uses a shared singleton pattern for view models:
- `DayCounterViewModel.shared` - Core streak and milestone logic
- `AppSettingsViewModel.shared` - User preferences
- `SessionTracker.shared` - Session tracking and tip prompts

All view models are injected as `@EnvironmentObject` through the app root.

## Development Commands

### Building and Running
```bash
# Open the Xcode project
open App/IWNDWYT/IWNDWYT.xcodeproj

# Build from command line (requires xcodebuild)
cd App/IWNDWYT
xcodebuild -scheme IWNDWYT -configuration Debug build

# Run tests
xcodebuild -scheme IWNDWYT -configuration Debug test
```

### Testing
- **Unit Tests**: `App/IWNDWYT/IWNDWYTTests/`
- **UI Tests**: `App/IWNDWYT/IWNDWYTUITests/`

Run tests through Xcode Test Navigator or via xcodebuild command above.

### Screenshots
The repository includes automation for App Store screenshots:
```bash
# Run screenshot automation (requires simulator)
./screenshot_automation.sh
```

## Debug Features

### DateProvider Debug System
In debug builds, `DateProvider` allows time manipulation for testing streak calculations:
- `DateProvider.offsetInDays` - Simulate future/past dates
- Automatically triggers UI refresh via `dateOffsetChanged` notification
- Reset with `DateProvider.reset()`

### Debug Panel
Available in debug builds only (`#if DEBUG`):
- Access via button in ContentView
- Test notifications, date manipulation, milestone triggers
- Reset data functionality

### Notification Testing
Debug methods in `MotivationManager`:
- `scheduleTestNotification(minutesFromNow:)` - Test notifications
- `scheduleDebugNotification(secondsFromNow:)` - Quick debug notifications
- `listPendingNotifications()` - View scheduled notifications

## Key Files

### Entry Point
- `App/IWNDWYT/IWNDWYT/IWNDWYTApp.swift` - App delegate and main entry point

### Core Logic
- `App/Models/StreakData.swift` - Data models for streaks
- `App/ViewModels/DayCounterViewModel.swift` - Main business logic
- `App/Models/MotivationManager.swift` - Notification scheduling
- `App/Models/DateProvider.swift` - Date abstraction for testing
- `App/Models/DataExportManager.swift` - Data export/import functionality

### Main Views
- `App/Views/MainTabView.swift` - Tab navigation container
- `App/Views/ContentView.swift` - Primary home screen
- `App/Views/CalendarView.swift` - Calendar with color-coded streak history
- `App/Views/MetricsView.swift` - Statistics and calendar integration
- `App/Views/MilestoneCelebrationView.swift` - Milestone celebrations
- `App/Views/StreakActionButtonView.swift` - Start/view streak button
- `App/Views/SettingsView.swift` - App settings and data management
- `App/Views/DataImportExportView.swift` - Data backup/restore interface

## Development Notes

### Streak Logic
- **Ending Streaks**: When a streak is ended, it creates a past streak ending on the last successful day (yesterday)
- **Starting Streaks**: New streaks can be started immediately - no same-day restart restrictions
- **Calendar Coloring**: Simple 5-rule system with no conflicting conditions

### Calendar Color System
The calendar uses a simple, predictable 5-rule system:
1. **Past Streaks = GREEN**: All days in completed successful streaks
2. **Active Streak Days (before today) = GREEN**: Days in current streak excluding today  
3. **Today = ALWAYS NEUTRAL**: Blank slate regardless of streak status
4. **Other Tracked Days = RED**: Relapse days between/after streaks
5. **Before Tracking = CLEAR**: Days before any streak data

### Milestone System
- Milestones are checked in `DayCounterViewModel.currentStreak` getter
- Global celebrations for all milestone achievements
- Prevents duplicate celebrations via `lastCelebratedStreak` tracking

### Debug Features
- **Date Simulation**: `DateProvider.offsetInDays` for testing different dates
- **Screenshot Data**: `DummyDataManager` generates realistic data for App Store screenshots
- **Debug Panel**: Access to notification testing, data manipulation, and state inspection

### Notification Permissions
App requests notification permissions on launch. Daily motivational notifications are scheduled when no active streak exists.

### Data Persistence
User data is stored in `UserDefaults` using JSON encoding. All data operations go through `DayCounterViewModel.save()`.

### Data Export/Import
The app includes comprehensive backup and restore capabilities:
- **Export**: Creates JSON files with versioned data format including metadata
- **Import**: Validates and restores data with automatic backup of current state
- **File Format**: JSON with version info, export date, device info, and full streak data
- **Validation**: Checks data integrity, version compatibility, and date reasonableness
- **Access**: Available through Settings → Data Management → Export & Import Data
- **Sharing**: iOS native share sheet for exporting files
- **File Picker**: Standard iOS document picker for importing files

### Testing Strategy
Use the debug panel and `DateProvider` offset to simulate different streak scenarios and milestone triggers without waiting real time.