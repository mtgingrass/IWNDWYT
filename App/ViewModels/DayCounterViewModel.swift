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
    
    @Published var sobrietyData: SobrietyData
    @Published var showingRatingRequest = false
    
    // Milestone celebration state
    @Published var showingMilestoneCelebration = false
    @Published var celebrationMilestone: Milestone?
    private var lastCelebratedStreak: Int = 0

    private let storageKey = "sobriety_data"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(SobrietyData.self, from: data) {
            sobrietyData = decoded
        } else {
            // First time user
            sobrietyData = SobrietyData(currentStartDate: DateProvider.now, pastStreaks: [], isActiveStreak: false)
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
        if let encoded = try? JSONEncoder().encode(sobrietyData) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    // End current streak without starting a new one
    func endStreak() {
        guard sobrietyData.isActiveStreak else { return }
        
        let today = DateProvider.now
        let length = Calendar.current.dateComponents([.day], from: sobrietyData.currentStartDate, to: today).day ?? 0

        let finishedStreak = Streak(
            id: UUID(),
            startDate: sobrietyData.currentStartDate,
            endDate: today,
            length: length
        )

        sobrietyData.pastStreaks.append(finishedStreak)
        sobrietyData.isActiveStreak = false
        save()
        MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: false)
    }
    
    // Start a new streak
    func startStreak() {
        sobrietyData.currentStartDate = DateProvider.now
        sobrietyData.isActiveStreak = true
        
        // Reset milestone tracking for new streak
        lastCelebratedStreak = -1  // Set to -1 so day 0 and day 1 can be detected properly
        showingMilestoneCelebration = false
        celebrationMilestone = nil
        print("🔄 Milestone tracking reset for new streak")
        
        save()
        MotivationManager.shared.cancelAllNotifications()
    }
    
    // Start a new streak with custom date
    func startStreakWithCustomDate(_ date: Date) {
        sobrietyData.currentStartDate = date
        sobrietyData.isActiveStreak = true
        
        // Reset milestone tracking for new streak
        lastCelebratedStreak = -1
        showingMilestoneCelebration = false
        celebrationMilestone = nil
        print("🔄 Milestone tracking reset for new streak with custom date")
        
        save()
        MotivationManager.shared.cancelAllNotifications()
    }
    
    func cancelStreak() {
        // Only cancel if the streak was started today
        if sobrietyData.isActiveStreak && 
           Calendar.current.isDate(sobrietyData.currentStartDate, inSameDayAs: DateProvider.now) {
            sobrietyData.isActiveStreak = false
            save()
            MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: false)
        }
    }
    
    // Reset all data
    func resetAllData() {
        sobrietyData = SobrietyData(currentStartDate: DateProvider.now, pastStreaks: [], isActiveStreak: false)
        
        // Clear UserDefaults for this key
        UserDefaults.standard.removeObject(forKey: storageKey)
        
        // Reset the start date flag so the picker shows again
        AppSettingsViewModel.shared.resetStartDateFlag()
        
        // Save the fresh state
        save()
        
        // Force a refresh of the UI
        objectWillChange.send()
        MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: false)
    }
    
    func refresh() {
        objectWillChange.send()
    }

    // Calculate days since currentStartDate
    var currentStreak: Int {
        guard sobrietyData.isActiveStreak else { return 0 }
        let streak = Calendar.current.dateComponents([.day], from: sobrietyData.currentStartDate, to: DateProvider.now).day ?? 0
        
        // Check for milestone celebrations and rating requests when streak is calculated
        DispatchQueue.main.async {
            self.checkForMilestoneCelebration(newStreak: streak)
            
            RatingManager.shared.checkForRatingRequest(
                currentStreak: streak,
                isActiveStreak: self.sobrietyData.isActiveStreak
            )
        }
        
        return streak
    }

    var totalAttempts: Int {
        sobrietyData.pastStreaks.count + (sobrietyData.isActiveStreak ? 1 : 0)
    }

    var longestStreak: Int {
        let past = sobrietyData.pastStreaks.map { $0.length }.max() ?? 0
        return max(past, currentStreak)
    }
    
    var isActiveStreak: Bool {
        sobrietyData.isActiveStreak
    }
    
    // MARK: - Milestone Celebrations
    
    private let milestones = [
        Milestone(days: 1, title: "Day 1", emoji: "🌱"),
        Milestone(days: 2, title: "2 Days", emoji: "🍀"),
        Milestone(days: 5, title: "5 Days", emoji: "⭐️"),
        Milestone(days: 7, title: "1 Week", emoji: "🌟"),
        Milestone(days: 14, title: "2 Weeks", emoji: "🎯"),
        Milestone(days: 30, title: "1 Month", emoji: "🏆"),
        Milestone(days: 60, title: "2 Months", emoji: "💫"),
        Milestone(days: 90, title: "3 Months", emoji: "🌙"),
        Milestone(days: 180, title: "6 Months", emoji: "🌞"),
        Milestone(days: 365, title: "1 Year", emoji: "👑"),
        Milestone(days: 730, title: "2 Years", emoji: "🎊"),
        Milestone(days: 1095, title: "3 Years", emoji: "⚡️")
    ]
    
    private func checkForMilestoneCelebration(newStreak: Int) {
        print("🔍 Checking milestones: newStreak=\(newStreak), lastCelebrated=\(lastCelebratedStreak), isActive=\(sobrietyData.isActiveStreak)")
        
        // Only check if we have an active streak and streak has increased
        guard sobrietyData.isActiveStreak, newStreak > lastCelebratedStreak else { 
            print("🔍 Milestone check skipped: active=\(sobrietyData.isActiveStreak), increased=\(newStreak > lastCelebratedStreak)")
            return 
        }
        
        // Find newly completed milestones
        let newlyCompleted = milestones.filter { milestone in
            newStreak >= milestone.days && lastCelebratedStreak < milestone.days
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
    
    // MARK: - Metrics
    
    var averageStreakLength: Int {
        let streaks = sobrietyData.pastStreaks
        guard !streaks.isEmpty else { return currentStreak }
        let totalDays = streaks.reduce(0) { $0 + $1.length } + currentStreak
        return totalDays / (streaks.count + 1)
    }
    
    var totalSoberDays: Int {
        sobrietyData.pastStreaks.reduce(0) { $0 + $1.length } + currentStreak
    }
    
    var successRate: Double {
        // Count total tracked days (only days within streaks)
        var totalTrackedDays = sobrietyData.pastStreaks.reduce(0) { $0 + $1.length }
        
        // Add current streak days if active
        if sobrietyData.isActiveStreak {
            let currentDays = Calendar.current.dateComponents([.day], from: sobrietyData.currentStartDate, to: DateProvider.now).day ?? 0
            totalTrackedDays += currentDays
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
    
}
