# IWNDWYT - App Store Review Testing Guide

**Version:** 1.1.0 (Build 2)  
**Date:** July 2025  
**Target:** App Store Review Team

## Overview
IWNDWYT (I Will Not Drink With You Today) is a habit tracking app designed to help users maintain positive streaks, celebrate milestones, and stay motivated through their personal journey.

## Core Features to Review

### 1. **Streak Tracking** ⭐ PRIMARY FEATURE
- **What:** Daily counter showing consecutive days of positive habit maintenance
- **Test:** Open app, verify streak counter displays correctly
- **Expected:** Clear, prominent display of current streak days

### 2. **Milestone Celebrations** ⭐ KEY FEATURE  
- **What:** Animated celebrations at significant milestones (1, 3, 7, 14, 30, 60, 90+ days)
- **Test:** Reach milestone days (can be simulated by changing device date if needed)
- **Expected:** Full-screen celebration popup with animations and congratulatory message

### 3. **Progress Visualization**
- **What:** Visual progress rings and charts showing streak progress
- **Test:** Navigate through different views, observe progress indicators
- **Expected:** Smooth animations, clear visual feedback

### 4. **Motivational Notifications** 
- **What:** Optional daily reminders and encouragement
- **Test:** Enable notifications in Settings, verify permission request
- **Expected:** System permission dialog, proper notification scheduling

### 5. **Data Management**
- **What:** Start new streaks, reset data, view statistics  
- **Test:** Use "Reset All Data" in Settings, start new streak
- **Expected:** Clean reset functionality, data persistence

## Navigation Flow Testing

### Initial Setup
1. **First Launch:** Should show intro/onboarding
2. **Date Selection:** Choose streak start date
3. **Main Interface:** Navigate to primary tracking view

### Core Navigation
1. **Tab Navigation:** Switch between main views
2. **Settings Access:** Gear icon in top-right
3. **About/Support:** Access app information and contact

### Settings Menu
1. **Notifications Toggle:** Enable/disable reminders
2. **Data Reset:** Destructive action with confirmation
3. **Support Links:** Contact developer, rate app
4. **Resources:** External links (r/stopdrinking)

## Permissions & Privacy

### Notification Permissions
- **When:** User enables motivational notifications
- **Expected:** Standard iOS permission dialog
- **Behavior:** Graceful handling of denied permissions

### Data Storage
- **Local Only:** All data stored locally on device
- **No Network:** App functions entirely offline
- **Privacy:** No personal data collected or transmitted

## Edge Cases & Error Handling

### Date Handling
- **Time Zones:** Verify streak calculations across time zone changes  
- **Date Changes:** Handle system date modifications appropriately
- **Calendar Edge Cases:** Test month/year boundaries

### App Lifecycle
- **Background/Foreground:** Maintain state when switching apps
- **Termination/Restart:** Preserve data and settings
- **iOS Version Compatibility:** Test on minimum supported iOS version

## Accessibility & Usability

### VoiceOver Support
- **Navigation:** All interactive elements accessible
- **Content:** Meaningful labels for streak counters and buttons
- **Announcements:** Clear feedback for actions

### Visual Accessibility  
- **Text Size:** Support Dynamic Type scaling
- **Contrast:** Readable in all lighting conditions
- **Color:** Information not conveyed by color alone

## Performance Expectations

### Launch Time
- **Cold Start:** < 2 seconds to main interface
- **Warm Start:** < 1 second

### Memory Usage
- **Baseline:** Minimal memory footprint
- **Animations:** Smooth 60fps performance
- **Background:** Efficient when not active

## App Store Guidelines Compliance

### Content Guidelines
- **Health & Wellness:** Supportive, not medical advice
- **User Safety:** Positive, encouraging messaging only
- **Appropriate Content:** Family-friendly interface

### Technical Requirements
- **iOS Compatibility:** iOS 18.0+
- **Device Support:** iPhone and iPad
- **Architecture:** Universal binary

---

## Quick Test Checklist for Reviewers

- [ ] App launches without crashes
- [ ] Streak counter displays and updates
- [ ] Milestone celebrations trigger appropriately  
- [ ] Settings menu functions correctly
- [ ] Notifications permission handled properly
- [ ] Data reset works with confirmation
- [ ] External links open correctly
- [ ] App responds to home button/gestures
- [ ] No inappropriate content or crashes
- [ ] Accessibility features work with VoiceOver

**Estimated Review Time:** 15-20 minutes for comprehensive testing