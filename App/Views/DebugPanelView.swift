import SwiftUI

#if DEBUG
struct DebugPanelView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dayCounterViewModel: DayCounterViewModel
    @EnvironmentObject private var settings: AppSettingsViewModel
    @EnvironmentObject private var sessionTracker: SessionTracker
    
    @State private var offset = DateProvider.offsetInDays
    @State private var showingResetAlert = false
    @State private var debugNotificationHour = MotivationManager.debugNotificationHour
    @State private var debugNotificationMinute = MotivationManager.debugNotificationMinute
    @State private var testNotificationMinutes = 1
    @State private var feedbackMessage = ""
    @State private var showingFeedback = false

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
            
            Section(header: Text("Notifications")) {
                // Notification Time
                HStack {
                    Text("Daily Time:")
                    Spacer()
                    Text("\(debugNotificationHour):\(String(format: "%02d", debugNotificationMinute))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Stepper("Hour: \(debugNotificationHour)", value: $debugNotificationHour, in: 0...23)
                        .onChange(of: debugNotificationHour) {
                            MotivationManager.debugNotificationHour = debugNotificationHour
                            showFeedback("Time updated to \(debugNotificationHour):\(String(format: "%02d", debugNotificationMinute))")
                            if settings.motivationalNotificationsEnabled {
                                let isActiveStreak = dayCounterViewModel.isActiveStreak
                                MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: isActiveStreak)
                            }
                        }
                }
                
                HStack {
                    Stepper("Minute: \(debugNotificationMinute)", value: $debugNotificationMinute, in: 0...59, step: 15)
                        .onChange(of: debugNotificationMinute) {
                            MotivationManager.debugNotificationMinute = debugNotificationMinute
                            showFeedback("Time updated to \(debugNotificationHour):\(String(format: "%02d", debugNotificationMinute))")
                            if settings.motivationalNotificationsEnabled {
                                let isActiveStreak = dayCounterViewModel.isActiveStreak
                                MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: isActiveStreak)
                            }
                        }
                }
                
                Divider()
                
                // Quick Test
                VStack(spacing: 12) {
                    Text("Quick Test")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        Button("30 sec") {
                            MotivationManager.shared.scheduleDebugNotification(secondsFromNow: 30)
                            showFeedback("✅ Notification scheduled for 30 seconds")
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(.white)
                        .tint(.orange)
                        
                        Button("1 min") {
                            MotivationManager.shared.scheduleTestNotification(minutesFromNow: 1)
                            showFeedback("✅ Notification scheduled for 1 minute")
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Test Popup") {
                            sessionTracker.showMotivationalPopup()
                            showFeedback("✅ Motivational popup triggered")
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.purple)
                    }
                }
                
                Divider()
                
                // Management
                VStack(spacing: 8) {
                    Text("Management")
                        .font(.headline)
                    
                    HStack {
                        Button("Reschedule Daily") {
                            let isActiveStreak = dayCounterViewModel.isActiveStreak
                            MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: isActiveStreak)
                            showFeedback("✅ Daily notifications rescheduled")
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(.white)
                        .tint(.green)
                        
                        Button("Cancel All") {
                            MotivationManager.shared.cancelAllNotifications()
                            showFeedback("❌ All notifications cancelled")
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
                
                // Feedback Display
                if showingFeedback {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(feedbackMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    .transition(.opacity)
                }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    // This will be handled by the presenting view's @Environment
                    dismiss()
                }
            }
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllUserDefaults()
            }
        } message: {
            Text("This will clear all user defaults and reset the app to a fresh install state. This action cannot be undone.")
        }
        .onAppear {
            // Sync debug panel state with MotivationManager
            debugNotificationHour = MotivationManager.debugNotificationHour
            debugNotificationMinute = MotivationManager.debugNotificationMinute
        }
    }
    
    private func showFeedback(_ message: String) {
        feedbackMessage = message
        withAnimation(.easeInOut(duration: 0.3)) {
            showingFeedback = true
        }
        
        // Auto-hide after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingFeedback = false
            }
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
        
        // Reset milestone tracking
        dayCounterViewModel.resetMilestoneTracking()
        
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
