//
//  DayCounterViewModel.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import Foundation
import SwiftUI

class DayCounterViewModel: ObservableObject {
    static let shared = DayCounterViewModel()
    
    @Published var sobrietyData: SobrietyData

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
        MotivationManager.shared.scheduleMotivationalNotifications()
    }
    
    // Start a new streak
    func startStreak() {
        sobrietyData.currentStartDate = DateProvider.now
        sobrietyData.isActiveStreak = true
        save()
        MotivationManager.shared.cancelAllNotifications()
    }
    
    // Start a new streak with custom date
    func startStreakWithCustomDate(_ date: Date) {
        sobrietyData.currentStartDate = date
        sobrietyData.isActiveStreak = true
        save()
        MotivationManager.shared.cancelAllNotifications()
    }
    
    func cancelStreak() {
        // Only cancel if the streak was started today
        if sobrietyData.isActiveStreak && 
           Calendar.current.isDate(sobrietyData.currentStartDate, inSameDayAs: DateProvider.now) {
            sobrietyData.isActiveStreak = false
            save()
            MotivationManager.shared.scheduleMotivationalNotifications()
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
        MotivationManager.shared.scheduleMotivationalNotifications()
    }
    
    func refresh() {
        objectWillChange.send()
    }

    // Calculate days since currentStartDate
    var currentStreak: Int {
        guard sobrietyData.isActiveStreak else { return 0 }
        return Calendar.current.dateComponents([.day], from: sobrietyData.currentStartDate, to: DateProvider.now).day ?? 0
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
}
