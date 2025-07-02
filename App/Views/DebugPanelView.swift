import SwiftUI

#if DEBUG
struct DebugPanelView: View {
    @EnvironmentObject private var dayCounterViewModel: DayCounterViewModel
    @EnvironmentObject private var settings: AppSettingsViewModel
    @EnvironmentObject private var sessionTracker: SessionTracker
    
    @State private var offset = DateProvider.offsetInDays
    @State private var showingResetAlert = false
    @State private var debugNotificationHour = MotivationManager.debugNotificationHour
    @State private var debugNotificationMinute = MotivationManager.debugNotificationMinute
    @State private var testNotificationMinutes = 1

    var body: some View {
        Form {
            Section(header: Text("Debug: Simulated Time")) {
                Stepper("Days Offset: \(offset)", value: $offset, in: -30...365)
                    .onChange(of: offset) {
                        DateProvider.offsetInDays = offset
                        // Force refresh of any views relying on DateProvider.now
                        NotificationCenter.default.post(name: .dateOffsetChanged, object: nil)
                    }

                Button("Reset Offset") {
                    DateProvider.reset()
                    offset = 0
                }
            }
            
            Section(header: Text("Debug: Notifications")) {
                HStack {
                    Text("Notification Time:")
                    Spacer()
                    Stepper("\(debugNotificationHour):\(String(format: "%02d", debugNotificationMinute))", value: $debugNotificationHour, in: 0...23)
                        .onChange(of: debugNotificationHour) {
                            MotivationManager.debugNotificationHour = debugNotificationHour
                            // Reschedule notifications with new time if enabled
                            if settings.motivationalNotificationsEnabled {
                                let isActiveStreak = dayCounterViewModel.isActiveStreak
                                MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: isActiveStreak)
                            }
                        }
                }
                
                HStack {
                    Text("Minute:")
                    Spacer()
                    Stepper("\(debugNotificationMinute)", value: $debugNotificationMinute, in: 0...59)
                        .onChange(of: debugNotificationMinute) {
                            MotivationManager.debugNotificationMinute = debugNotificationMinute
                            // Reschedule notifications with new time if enabled
                            if settings.motivationalNotificationsEnabled {
                                let isActiveStreak = dayCounterViewModel.isActiveStreak
                                MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: isActiveStreak)
                            }
                        }
                }
                
                Divider()
                
                HStack {
                    Text("Test Notification:")
                    Spacer()
                    Stepper("\(testNotificationMinutes) min", value: $testNotificationMinutes, in: 1...60)
                }
                
                Button("Schedule Test Notification") {
                    MotivationManager.shared.scheduleTestNotification(minutesFromNow: testNotificationMinutes)
                }
                .foregroundColor(.blue)
                
                Button("Cancel Test Notifications") {
                    MotivationManager.shared.cancelTestNotifications()
                }
                .foregroundColor(.orange)
                
                Button("Reschedule Daily Notifications") {
                    let isActiveStreak = dayCounterViewModel.isActiveStreak
                    MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: isActiveStreak)
                }
                .foregroundColor(.green)
                
                Divider()
                
                Button("Test Motivational Popup") {
                    sessionTracker.showMotivationalPopup()
                }
                .foregroundColor(.purple)
                
                Button("Set Badge (1)") {
                    UIApplication.shared.applicationIconBadgeNumber = 1
                }
                .foregroundColor(.orange)
                
                Button("Clear Badge") {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                .foregroundColor(.red)
                
                Divider()
                
                Button("Check Streak Status") {
                    print("🔍 Streak status: hasChosenStartDate = \(settings.hasChosenStartDate)")
                    print("🔍 Active streak: \(dayCounterViewModel.isActiveStreak)")
                    print("🔍 Current badge number: \(UIApplication.shared.applicationIconBadgeNumber)")
                }
                .foregroundColor(.gray)
                
                Button("Check Notification Permissions") {
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        print("🔍 Notification settings:")
                        print("   - Authorization status: \(settings.authorizationStatus.rawValue)")
                        print("   - Alert setting: \(settings.alertSetting.rawValue)")
                        print("   - Badge setting: \(settings.badgeSetting.rawValue)")
                        print("   - Sound setting: \(settings.soundSetting.rawValue)")
                    }
                }
                .foregroundColor(.gray)
                
                Text("Current notification time will be used for daily motivational notifications")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            RatingDebugSection()
            
            Section(header: Text("Debug: App State")) {
                Button("Reset All User Defaults", role: .destructive) {
                    showingResetAlert = true
                }
                .foregroundColor(.red)
                
                Text("This will clear all app data and reset to a fresh install state")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Debug Panel")
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllUserDefaults()
            }
        } message: {
            Text("This will clear all user defaults and reset the app to a fresh install state. This action cannot be undone.")
        }
    }
    
    private func resetAllUserDefaults() {
        // Clear all UserDefaults keys used by the app
        UserDefaults.standard.removeObject(forKey: "sobriety_data")
        UserDefaults.standard.removeObject(forKey: "hasChosenStartDate")
        UserDefaults.standard.removeObject(forKey: "hasSeenIntro")
        
        // Reset DateProvider offset as well
        DateProvider.reset()
        offset = 0
        
        // Reset ViewModels to fresh state
        dayCounterViewModel.sobrietyData = SobrietyData(
            currentStartDate: DateProvider.now,
            pastStreaks: [],
            isActiveStreak: false
        )
        
        // Reset app settings using shared instance - this will trigger StartDatePickerView
        AppSettingsViewModel.shared.hasChosenStartDate = false
        
        // Force UI refresh
        dayCounterViewModel.objectWillChange.send()
        AppSettingsViewModel.shared.objectWillChange.send()
    }
}

struct RatingDebugSection: View {
    @StateObject private var ratingManager = RatingManager.shared
    @EnvironmentObject private var dayCounter: DayCounterViewModel
    
    var body: some View {
        Section("Rating System Debug") {
            VStack(alignment: .leading, spacing: 12) {
                // Debug Info Display - use detailedDebugInfo if you added the extension, otherwise debugInfo
                Text(ratingManager.detailedDebugInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                // Test Controls
                HStack {
                    Button("Force Rating Request") {
                        ratingManager.forceRatingRequest()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Reset Rating Data") {
                        ratingManager.resetRatingData()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Complete Reset") {
                        ratingManager.completeReset()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                
                // Simulate Optimal Conditions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Test Scenarios:")
                        .font(.headline)
                    
                    HStack {
                        Button("Day 3") {
                            simulateStreakDay(3)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Day 7") {
                            simulateStreakDay(7)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Day 14") {
                            simulateStreakDay(14)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Day 30") {
                            simulateStreakDay(30)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Current State
                HStack {
                    Text("Current Streak:")
                    Text("\(dayCounter.currentStreak) days")
                        .fontWeight(.bold)
                    Text("Active:")
                    Text(dayCounter.isActiveStreak ? "Yes" : "No")
                        .fontWeight(.bold)
                        .foregroundColor(dayCounter.isActiveStreak ? .green : .red)
                }
                .font(.caption)
                
                // Test rating eligibility
                Button("Test Rating Eligibility") {
                    let currentStreak = dayCounter.currentStreak
                    let isActive = dayCounter.isActiveStreak
                    let wouldShow = ratingManager.wouldShowRatingFor(streak: currentStreak, isActive: isActive)
                    let optimalConditions = ratingManager.testOptimalConditions(currentStreak: currentStreak)
                    
                    print("🧪 Rating Test Results:")
                    print("   Current streak: \(currentStreak), Active: \(isActive)")
                    print("   Would show rating: \(wouldShow)")
                    print("   Optimal conditions: \(optimalConditions)")
                    
                    if let nextMilestone = ratingManager.getNextMilestone(currentStreak: currentStreak) {
                        print("   Next milestone: Day \(nextMilestone)")
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(.blue)
            }
        }
    }
    
    private func simulateStreakDay(_ targetDay: Int) {
        // Calculate how many days to offset to reach target streak
        let currentStreak = dayCounter.currentStreak
        let daysToOffset = targetDay - currentStreak
        
        #if DEBUG
        // Temporarily set the date offset
        DateProvider.offsetInDays += daysToOffset
        
        // Trigger the rating check
        ratingManager.checkForRatingRequest(
            currentStreak: targetDay,
            isActiveStreak: true
        )
        
        // Post notification for UI refresh
        NotificationCenter.default.post(name: .dateOffsetChanged, object: nil)
        
        print("🧪 Simulated streak day \(targetDay), offset: \(DateProvider.offsetInDays)")
        #endif
    }
}
#endif
