# Manual Screenshot Guide for IWNDWYT

## Quick Manual Process

### Setup
1. **Use iOS Simulator** (better quality than device screenshots)
2. **Device Types Needed:**
   - iPhone 15 Pro Max (6.7" - App Store requirement)
   - iPhone 15 (6.1" - App Store requirement) 
   - iPad Pro 12.9" (App Store requirement)

### Screenshot Sequence

#### Core App Screens (Required)
1. **Main/Home Screen**
   - Shows current streak prominently
   - Clean, uncluttered view
   - Progress visualization visible

2. **Milestone Celebration**
   - Full-screen celebration popup
   - Confetti/animation effects
   - Congratulatory message

3. **Settings Screen**
   - All settings options visible
   - Toggle states shown
   - Professional layout

4. **About/Info Screen**
   - App information
   - Version details
   - Contact/support options

5. **Milestone Progress View**
   - Visual progress indicators
   - Multiple milestone states
   - Clean progress rings

#### Optional Screens (Nice to have)
6. **Intro/Onboarding**
   - First-time user experience
   - Date picker interface

7. **Notifications Permission**
   - iOS permission dialog
   - Settings integration

### Taking Screenshots

#### In iOS Simulator:
```bash
# Command line method
xcrun simctl io booted screenshot screenshot_name.png

# Or use Device → Screenshot in Simulator menu
```

#### Simulator Steps:
1. Open Xcode
2. Choose appropriate simulator device
3. Build and run IWNDWYT
4. Navigate to each screen
5. Device → Screenshot (or Cmd+S)
6. Save with descriptive names

### File Naming Convention

```
IWNDWYT_[Device]_[Screen]_[Version].png

Examples:
- IWNDWYT_iPhone15ProMax_MainScreen_v1.1.0.png
- IWNDWYT_iPhone15_MilestoneCelebration_v1.1.0.png
- IWNDWYT_iPadPro_Settings_v1.1.0.png
```

### App Store Specific Requirements

#### Image Specifications:
- **iPhone 6.7"**: 1290 x 2796 pixels
- **iPhone 6.1"**: 1179 x 2556 pixels  
- **iPad Pro 12.9"**: 2048 x 2732 pixels
- **Format**: PNG or JPEG
- **Max file size**: 500 MB per image

#### Best Practices:
- **Clean UI**: Remove debug elements
- **Representative Data**: Show realistic streak numbers
- **Visual Hierarchy**: Main features prominently displayed
- **No Sensitive Info**: Avoid personal data in screenshots

### Screenshot Organization

```
Screenshots/
├── AppStore/
│   ├── iPhone_6.7/
│   │   ├── 01_main_screen.png
│   │   ├── 02_milestone_celebration.png
│   │   └── 03_settings.png
│   ├── iPhone_6.1/
│   │   └── [same structure]
│   └── iPad_12.9/
│       └── [same structure]
├── Marketing/
│   └── [promotional screenshots]
└── Beta_Testing/
    └── [testing documentation screenshots]
```

## Quick 10-Minute Manual Process

1. **iPhone 15 Pro Max Simulator** (5 minutes)
   - Launch app → Screenshot main screen
   - Tap settings → Screenshot settings
   - Navigate back → Trigger milestone (change date if needed) → Screenshot
   - About screen → Screenshot

2. **Repeat for iPhone 15** (3 minutes)
   - Same sequence, different resolution

3. **iPad Pro 12.9"** (2 minutes)
   - Key screens only (main + settings)

**Total Time: ~10 minutes for core App Store requirements**