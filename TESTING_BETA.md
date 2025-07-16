# IWNDWYT - Beta Testing Guide

**Version:** 1.1.0 (Build 2)  
**Date:** July 2025  
**Target:** Beta Testers

## What's New in Version 1.1.0

### ✨ New Features
- **Global milestone celebrations** - Celebrations now appear throughout the app
- **Enhanced milestone animations** - More visual flair with particles and effects
- **Improved settings organization** - Cleaner layout with removed duplicate sections
- **Better notification debugging** - Fixed scheduling issues for daily reminders

### 🐛 Bug Fixes
- Fixed milestone celebrations not working after data reset
- Fixed string interpolation showing "(currentdaysstrong" instead of actual value
- Improved debug panel modal presentation (hides tab bar)
- Fixed daily notification repeating issue

---

## Comprehensive Testing Scenarios

### 🎯 Core Functionality Testing

#### Streak Management
- [ ] **Start New Streak**
  - Launch app fresh, set start date
  - Verify streak counter starts at Day 1
  - Test with past dates, future dates, today
  
- [ ] **Daily Progression** 
  - Open app on consecutive days
  - Verify counter increments properly
  - Test time zone changes/travel
  
- [ ] **Data Reset**
  - Use Settings → Reset All Data
  - Confirm destructive action dialog
  - Verify app returns to fresh state
  - Start new streak after reset

#### Milestone System ⭐ **PRIORITY TESTING**
- [ ] **Milestone Triggers**
  - Day 1: First day celebration
  - Day 3: Early milestone
  - Day 7: One week  
  - Day 14: Two weeks
  - Day 30: One month
  - Day 60, 90, 120: Extended milestones
  
- [ ] **Celebration Behavior**
  - Full-screen popup appears
  - Animations play smoothly  
  - Message shows correct day count
  - Celebration dismisses properly
  - Works from any screen in app
  
- [ ] **After Data Reset** ⚠️ **KNOWN ISSUE TO VERIFY**
  - Reset data completely
  - Start new streak
  - Verify Day 1 celebration still works
  - Test subsequent milestones (3, 7, etc.)

### 📱 User Interface Testing

#### Navigation & Layout
- [ ] **Tab Navigation**
  - Switch between all tabs
  - Verify selected state
  - Test gesture navigation
  
- [ ] **Settings Access**
  - Tap gear icon
  - Navigate through settings sections
  - Test all toggle switches
  
- [ ] **Modal Presentations**
  - About screen
  - Tip jar
  - Intro sequence (delete/reinstall app)

#### Visual & Animation Testing
- [ ] **Progress Visualizations**
  - Progress rings animate smoothly
  - Milestone progress updates correctly
  - Visual feedback for interactions
  
- [ ] **Celebration Animations**
  - Confetti/particle effects
  - Smooth transitions
  - No visual glitches or lag
  
- [ ] **Responsive Design**
  - Test on different screen sizes
  - Portrait/landscape orientation
  - Dynamic Type scaling

### 🔔 Notification Testing

#### Permission Handling
- [ ] **First Time Setup**
  - Enable notifications in Settings
  - Verify iOS permission dialog
  - Test "Allow" and "Don't Allow"
  
- [ ] **Permission States**
  - Denied: Shows "Open Settings" button
  - Not Determined: Shows "Request Permission"  
  - Authorized: Shows green checkmark

#### Notification Delivery
- [ ] **Daily Notifications**
  - Enable motivational notifications
  - Wait for scheduled time (or change device time to test)
  - Verify notification appears in banner
  - Check notification content and actions
  
- [ ] **Notification Content**
  - Messages are motivational and appropriate
  - No placeholder text or errors
  - Tapping opens app correctly

### 🧪 Edge Case Testing

#### Date & Time Handling
- [ ] **Time Zone Changes**
  - Change device time zone
  - Verify streak calculation remains correct
  - Travel scenarios (if applicable)
  
- [ ] **Date Manipulation**
  - Change system date forward/backward
  - Verify app handles gracefully
  - Check streak logic integrity
  
- [ ] **Calendar Boundaries**
  - Test month transitions
  - Year boundaries (Dec 31 → Jan 1)
  - Leap year handling

#### App Lifecycle
- [ ] **Background/Foreground**
  - Switch apps while IWNDWYT open
  - Return after various time intervals
  - Verify state preservation
  
- [ ] **Force Quit & Restart**
  - Force close app
  - Relaunch and verify data integrity
  - Test multiple force quit cycles
  
- [ ] **Memory Pressure**
  - Use app with many other apps running
  - Test during low memory conditions

### 🌐 External Integration Testing

#### Links & External Navigation
- [ ] **Support Links**
  - Contact email opens mail app
  - Reddit link opens browser/Reddit app
  - Rate app link works (TestFlight limitation)
  
- [ ] **Tip Jar Functionality**
  - Navigate to tip jar
  - Test purchase flow (if implemented)
  - Handle cancelled purchases

### ♿ Accessibility Testing

#### VoiceOver Testing
- [ ] **Enable VoiceOver**
  - Navigate entire app with VoiceOver
  - Verify all elements are accessible
  - Check meaningful element descriptions
  
- [ ] **Content Reading**
  - Streak counter reads correctly
  - Button labels are descriptive
  - Progress indicators provide context

#### Visual Accessibility
- [ ] **Text Scaling**
  - Settings → Display & Brightness → Text Size
  - Test largest accessibility sizes
  - Verify layout doesn't break
  
- [ ] **Color & Contrast**
  - Test in bright sunlight
  - Verify readability for color-blind users
  - Check high contrast mode

### 📊 Performance Testing

#### Launch Performance
- [ ] **Cold Start** (app not in memory)
  - Time from tap to usable interface
  - Target: < 2 seconds
  
- [ ] **Warm Start** (app in background)
  - Time to restore interface
  - Target: < 1 second

#### Runtime Performance  
- [ ] **Animation Smoothness**
  - 60fps during milestone celebrations
  - Smooth scrolling in all lists
  - No stutters during transitions
  
- [ ] **Memory Usage**
  - Monitor in Xcode Instruments (if available)
  - No significant memory leaks
  - Stable usage over extended sessions

---

## 🐛 Bug Reporting Guidelines

When you find an issue, please include:

### Required Information
- **iOS Version:** (e.g., iOS 17.5.1)
- **Device Model:** (e.g., iPhone 14 Pro)
- **App Version:** 1.1.0 (Build 2)
- **Steps to Reproduce:** Detailed steps
- **Expected Behavior:** What should happen
- **Actual Behavior:** What actually happened

### Optional but Helpful
- **Screenshots/Screen Recording:** Visual evidence
- **Frequency:** Does it happen every time?
- **Workarounds:** Any way to avoid the issue?
- **Impact:** How severely does it affect usage?

### Contact Methods
- **Email:** iwndwytoday@markgingrass.com
- **TestFlight Feedback:** Use built-in TestFlight feedback
- **GitHub Issues:** (if you have access to repo)

---

## 📋 Quick Test Session Checklist

**30-Minute Test Session:**
- [ ] Launch app, verify basic functionality
- [ ] Test milestone celebration (change date if needed)
- [ ] Enable/disable notifications
- [ ] Navigate all major screens
- [ ] Test data reset and new streak creation
- [ ] Check one accessibility feature
- [ ] Report any issues found

**Extended Test Session (2+ hours):**
- [ ] Complete all sections above
- [ ] Test with real daily usage over multiple days
- [ ] Deep dive into edge cases
- [ ] Performance monitoring
- [ ] Cross-device testing (if multiple devices available)

---

## 🎯 Priority Areas for This Release

1. **Milestone celebrations after data reset** - Previously broken, now fixed
2. **Global milestone celebrations** - New feature, test thoroughly
3. **Notification scheduling** - Recently fixed bugs
4. **Settings UI improvements** - Clean up duplicate sections
5. **String interpolation** - Fixed display bugs

**Thank you for beta testing! Your feedback helps make IWNDWYT better for everyone in recovery. 💙**