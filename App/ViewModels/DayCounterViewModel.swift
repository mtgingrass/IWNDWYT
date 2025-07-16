//
//  DayCounterViewModel.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import Foundation
import SwiftUI

// Shared milestone structure
struct Milestone: Identifiable {
    let id = UUID()
    let days: Int
    let title: String
    let emoji: String
}

class DayCounterViewModel: ObservableObject {
    static let shared = DayCounterViewModel()
    
    @Published var streakData: StreakData
    @Published var showingRatingRequest = false
    
    // Milestone celebration state
    @Published var showingMilestoneCelebration = false
    @Published var celebrationMilestone: Milestone?
    private var lastCelebratedStreak: Int = 0
    
    // Removed same-day restart feature for simplicity

    private let storageKey = "streak_data"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(StreakData.self, from: data) {
            streakData = decoded
        } else {
            // First time user
            streakData = StreakData(currentStartDate: DateProvider.now, pastStreaks: [], isActiveStreak: false)
            save()
        }
        
        // Initialize milestone tracking
        resetMilestoneTracking()
        
        #if DEBUG
        NotificationCenter.default.addObserver(forName: .dateOffsetChanged, object: nil, queue: .main) { [weak self] _ in
            self?.refresh()
        }
        #endif
    }

    // Save to UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(streakData) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    // End current streak without starting a new one
    func endStreak() {
        guard streakData.isActiveStreak else { return }
        
        let today = DateProvider.now
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        
        // Only create a streak if there were successful days (length > 0)
        let length = Calendar.current.dateComponents([.day], from: streakData.currentStartDate, to: yesterday).day ?? 0
        let inclusiveLength = max(0, length + 1)
        
        if length > 0 {
            let finishedStreak = Streak(
                id: UUID(),
                startDate: streakData.currentStartDate,
                endDate: yesterday, // Last successful day
                length: inclusiveLength
            )
            streakData.pastStreaks.append(finishedStreak)
        }
        
        // Streak ended - no same-day restart allowed
        streakData.isActiveStreak = false
        save()
        MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: false)
    }
    
    // Start a new streak
    func startStreak() {
        performStartStreak()
    }
    
    private func performStartStreak(startDate: Date = DateProvider.now) {
        streakData.currentStartDate = startDate
        streakData.isActiveStreak = true
        
        // Reset milestone tracking for new streak
        lastCelebratedStreak = -1  // Set to -1 so day 0 and day 1 can be detected properly
        showingMilestoneCelebration = false
        celebrationMilestone = nil
        print("🔄 Milestone tracking reset for new streak")
        
        save()
        
        // Cancel motivation notifications and schedule encouragement notifications
        MotivationManager.shared.cancelAllNotifications()
        
        // Calculate current streak day for the encouragement message
        let currentDay = max(0, currentStreak)
        MotivationManager.shared.scheduleStreakEncouragementIfNeeded(
            streakActive: true,
            currentStreakDay: currentDay
        )
    }
    
    // Start a new streak with custom date
    func startStreakWithCustomDate(_ date: Date) {
        streakData.currentStartDate = date
        streakData.isActiveStreak = true
        
        // Reset milestone tracking for new streak
        lastCelebratedStreak = -1
        showingMilestoneCelebration = false
        celebrationMilestone = nil
        print("🔄 Milestone tracking reset for new streak with custom date")
        
        save()
        
        // Cancel motivation notifications and schedule encouragement notifications
        MotivationManager.shared.cancelAllNotifications()
        
        // Calculate current streak day for the encouragement message
        let currentDay = Calendar.current.dateComponents([.day], from: date, to: DateProvider.now).day ?? 0
        let inclusiveCurrentDay = max(0, currentDay + 1)
        MotivationManager.shared.scheduleStreakEncouragementIfNeeded(
            streakActive: true,
            currentStreakDay: inclusiveCurrentDay
        )
    }
    
    func cancelStreak() {
        // Only cancel if the streak was started today
        if streakData.isActiveStreak && 
           Calendar.current.isDate(streakData.currentStartDate, inSameDayAs: DateProvider.now) {
            streakData.isActiveStreak = false
            save()
            MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: false)
        }
    }
    
    // Reset all data
    func resetAllData() {
        streakData = StreakData(currentStartDate: DateProvider.now, pastStreaks: [], isActiveStreak: false)
        
        // Clear UserDefaults for this key
        UserDefaults.standard.removeObject(forKey: storageKey)
        
        // Reset milestone tracking
        resetMilestoneTracking()
        
        // Reset the start date flag so the picker shows again
        AppSettingsViewModel.shared.resetStartDateFlag()
        
        // Save the fresh state
        save()
        
        // Force a refresh of the UI
        objectWillChange.send()
        MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: false)
        
        print("🔄 All data reset to initial state")
    }
    
    func refresh() {
        objectWillChange.send()
    }

    // Calculate days since currentStartDate
    var currentStreak: Int {
        guard streakData.isActiveStreak else { return 0 }
        let streak = Calendar.current.dateComponents([.day], from: streakData.currentStartDate, to: DateProvider.now).day ?? 0
        let inclusiveStreak = max(0, streak + 1)
        
        // Check for milestone celebrations and rating requests when streak is calculated
        DispatchQueue.main.async {
            self.checkForMilestoneCelebration(newStreak: inclusiveStreak)
            
            RatingManager.shared.checkForRatingRequest(
                currentStreak: inclusiveStreak,
                isActiveStreak: self.streakData.isActiveStreak
            )
        }
        
        return inclusiveStreak
    }

    var totalAttempts: Int {
        streakData.pastStreaks.count + (streakData.isActiveStreak ? 1 : 0)
    }

    var longestStreak: Int {
        let past = streakData.pastStreaks.map { $0.length }.max() ?? 0
        let currentCompleted = streakData.isActiveStreak ? max(0, currentStreak - 1) : 0
        return max(past, currentCompleted)
    }
    
    var isActiveStreak: Bool {
        streakData.isActiveStreak
    }
    
    // MARK: - Milestone Celebrations
    
    private var milestones: [Milestone] {
        return [
            Milestone(days: 1, title: NSLocalizedString("milestone_day_1", comment: "Day 1 milestone"), emoji: "🌱"),
            Milestone(days: 2, title: NSLocalizedString("milestone_2_days", comment: "2 Days milestone"), emoji: "🍀"),
            Milestone(days: 5, title: NSLocalizedString("milestone_5_days", comment: "5 Days milestone"), emoji: "⭐️"),
            Milestone(days: 7, title: NSLocalizedString("milestone_1_week", comment: "1 Week milestone"), emoji: "🌟"),
            Milestone(days: 14, title: NSLocalizedString("milestone_2_weeks", comment: "2 Weeks milestone"), emoji: "🎯"),
            Milestone(days: 30, title: NSLocalizedString("milestone_1_month", comment: "1 Month milestone"), emoji: "🏆"),
            Milestone(days: 60, title: NSLocalizedString("milestone_2_months", comment: "2 Months milestone"), emoji: "💫"),
            Milestone(days: 90, title: NSLocalizedString("milestone_3_months", comment: "3 Months milestone"), emoji: "🌙"),
            Milestone(days: 180, title: NSLocalizedString("milestone_6_months", comment: "6 Months milestone"), emoji: "🌞"),
            Milestone(days: 365, title: NSLocalizedString("milestone_1_year", comment: "1 Year milestone"), emoji: "👑"),
            Milestone(days: 730, title: NSLocalizedString("milestone_2_years", comment: "2 Years milestone"), emoji: "🎊"),
            Milestone(days: 1095, title: NSLocalizedString("milestone_3_years", comment: "3 Years milestone"), emoji: "⚡️")
        ]
    }
    
    private func checkForMilestoneCelebration(newStreak: Int) {
        print("🔍 Checking milestones: newStreak=\(newStreak), lastCelebrated=\(lastCelebratedStreak), isActive=\(streakData.isActiveStreak)")
        
        // Only check if we have an active streak and streak has increased
        guard streakData.isActiveStreak, newStreak > lastCelebratedStreak else { 
            print("🔍 Milestone check skipped: active=\(streakData.isActiveStreak), increased=\(newStreak > lastCelebratedStreak)")
            return 
        }
        
        // Find newly completed milestones
        let newlyCompleted = milestones.filter { milestone in
            (newStreak - 1) >= milestone.days && lastCelebratedStreak < milestone.days
        }
        
        print("🔍 Newly completed milestones: \(newlyCompleted.map { "\($0.days) days" })")
        
        // Show celebration for the highest milestone achieved
        if let highestMilestone = newlyCompleted.max(by: { $0.days < $1.days }) {
            triggerMilestoneCelebration(milestone: highestMilestone)
        }
        
        lastCelebratedStreak = newStreak
        print("🔍 Updated lastCelebratedStreak to: \(lastCelebratedStreak)")
    }
    
    private func triggerMilestoneCelebration(milestone: Milestone) {
        // Show all milestone celebrations globally (all milestones are worth celebrating!)
        let allMilestones = [1, 2, 5, 7, 14, 30, 60, 90, 180, 365, 730, 1095]
        guard allMilestones.contains(milestone.days) else { return }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Show celebration
        celebrationMilestone = milestone
        showingMilestoneCelebration = true
        
        print("🎉 Global milestone celebration triggered for: \(milestone.title)")
    }
    
    // Reset milestone tracking (useful after data resets)
    func resetMilestoneTracking() {
        lastCelebratedStreak = -1  // Set to -1 so all milestones can be detected fresh
        showingMilestoneCelebration = false
        celebrationMilestone = nil
        print("🔄 Milestone tracking reset")
    }
    
    // Same-day restart feature removed for simplicity
    
    // MARK: - Metrics
    
    var averageStreakLength: Int {
        let streaks = streakData.pastStreaks
        guard !streaks.isEmpty else { return currentStreak }
        let totalDays = streaks.reduce(0) { $0 + $1.length } + currentStreak
        return totalDays / (streaks.count + 1)
    }
    
    var totalSoberDays: Int {
        streakData.pastStreaks.reduce(0) { $0 + $1.length } + currentStreak
    }
    
    var successRate: Double {
        // Count total tracked days (only days within streaks)
        var totalTrackedDays = streakData.pastStreaks.reduce(0) { $0 + $1.length }
        
        // Add current streak days if active
        if streakData.isActiveStreak {
            let currentDays = Calendar.current.dateComponents([.day], from: streakData.currentStartDate, to: DateProvider.now).day ?? 0
            let inclusiveCurrentDays = max(0, currentDays + 1)
            totalTrackedDays += inclusiveCurrentDays
        }
        
        // If we haven't tracked any days, return 100% (fresh start)
        guard totalTrackedDays > 0 else { return 100.0 }
        
        // Success rate is total sober days divided by total tracked days
        return (Double(totalSoberDays) / Double(totalTrackedDays)) * 100
    }
    func checkForRatingRequest() {
        RatingManager.shared.checkForRatingRequest(
            currentStreak: currentStreak,
            isActiveStreak: isActiveStreak
        )
    }
    
    // MARK: - Data Export/Import
    
    func exportData() -> Result<URL, DataExportError> {
        return DataExportManager.shared.exportData(streakData)
    }
    
    func importData(from url: URL) -> Result<String, DataExportError> {
        let result = DataExportManager.shared.importData(from: url)
        
        switch result {
        case .success(let importedData):
            // Create backup of current data before importing
            let backupResult = DataExportManager.shared.exportData(streakData)
            
            // Import the new data
            streakData = importedData
            
            // Reset milestone tracking for imported data
            resetMilestoneTracking()
            
            // Save imported data
            save()
            
            // Force UI refresh
            objectWillChange.send()
            
            // Update notifications based on new streak state
            if streakData.isActiveStreak {
                let currentDay = max(0, currentStreak)
                MotivationManager.shared.scheduleStreakEncouragementIfNeeded(
                    streakActive: true,
                    currentStreakDay: currentDay
                )
            } else {
                MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: false)
            }
            
            let message = "Data imported successfully! Your streak data has been restored."
            if case .success(let backupURL) = backupResult {
                return .success(message + " A backup of your previous data was created at: \(backupURL.lastPathComponent)")
            } else {
                return .success(message)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getExportPreview() -> String {
        print("🔍 DayCounterViewModel.getExportPreview called")
        let preview = DataExportManager.shared.getExportPreview(streakData)
        print("🔍 Generated preview: \(preview)")
        return preview
    }
    
    func getImportPreview(from url: URL) -> Result<String, DataExportError> {
        return DataExportManager.shared.getImportPreview(url)
    }
    
}
