//
//  DummyDataManager.swift
//  IWNDWYT
//
//  Created by Claude Code on 7/3/25.
//

import Foundation

#if DEBUG
class DummyDataManager {
    static let shared = DummyDataManager()
    private init() {}
    
    // Storage key for dummy data state
    private let dummyDataActiveKey = "dummy_data_active"
    
    var isDummyDataActive: Bool {
        get { UserDefaults.standard.bool(forKey: dummyDataActiveKey) }
        set { UserDefaults.standard.set(newValue, forKey: dummyDataActiveKey) }
    }
    
    // MARK: - Dummy Data Scenarios
    
    enum DummyDataScenario: String, CaseIterable {
        case successStory = "Success Story"
        case strugglingBeginner = "Struggling Beginner" 
        case steadyProgress = "Steady Progress"
        case perfectRecord = "Perfect Record"
        case recentSetback = "Recent Setback"
        
        var description: String {
            switch self {
            case .successStory:
                return "Long streaks with few setbacks, showing recovery progress"
            case .strugglingBeginner:
                return "Multiple short attempts, recent active streak"
            case .steadyProgress:
                return "Gradually improving streak lengths over time"
            case .perfectRecord:
                return "One perfect streak since January 1st"
            case .recentSetback:
                return "Had long streak, recent break, now rebuilding"
            }
        }
    }
    
    // MARK: - Data Generation
    
    func generateDummyData(scenario: DummyDataScenario) -> StreakData {
        let startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let today = DateProvider.now
        
        switch scenario {
        case .successStory:
            return generateSuccessStoryData(from: startDate, to: today)
        case .strugglingBeginner:
            return generateStrugglingBeginnerData(from: startDate, to: today)
        case .steadyProgress:
            return generateSteadyProgressData(from: startDate, to: today)
        case .perfectRecord:
            return generatePerfectRecordData(from: startDate, to: today)
        case .recentSetback:
            return generateRecentSetbackData(from: startDate, to: today)
        }
    }
    
    // MARK: - Scenario Implementations
    
    private func generateSuccessStoryData(from startDate: Date, to endDate: Date) -> StreakData {
        var pastStreaks: [Streak] = []
        var currentDate = startDate
        
        // Early short attempts (Jan-Feb)
        pastStreaks.append(createStreak(start: currentDate, length: 3))
        currentDate = Calendar.current.date(byAdding: .day, value: 5, to: currentDate)!
        
        pastStreaks.append(createStreak(start: currentDate, length: 12))
        currentDate = Calendar.current.date(byAdding: .day, value: 15, to: currentDate)!
        
        // Better attempt (March)
        pastStreaks.append(createStreak(start: currentDate, length: 28))
        currentDate = Calendar.current.date(byAdding: .day, value: 32, to: currentDate)!
        
        // Long successful streak (April-May) 
        pastStreaks.append(createStreak(start: currentDate, length: 47))
        currentDate = Calendar.current.date(byAdding: .day, value: 50, to: currentDate)!
        
        // June attempt (for last month data)
        let juneStart = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 5))!
        pastStreaks.append(createStreak(start: juneStart, length: 18))
        
        // Current streak started in early July (for this month data)
        let currentStart = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 1))!
        
        return StreakData(
            currentStartDate: currentStart,
            pastStreaks: pastStreaks,
            isActiveStreak: true
        )
    }
    
    private func generateStrugglingBeginnerData(from startDate: Date, to endDate: Date) -> StreakData {
        var pastStreaks: [Streak] = []
        var currentDate = startDate
        
        // Many short attempts throughout the year
        let attemptLengths = [1, 0, 2, 1, 0, 3, 1, 5, 2, 1, 0, 4, 7, 2, 0, 1, 14, 1, 0, 8]
        
        for length in attemptLengths {
            if length > 0 {
                pastStreaks.append(createStreak(start: currentDate, length: length))
                currentDate = Calendar.current.date(byAdding: .day, value: length + Int.random(in: 1...5), to: currentDate)!
            } else {
                // Just skip a few days
                currentDate = Calendar.current.date(byAdding: .day, value: Int.random(in: 2...7), to: currentDate)!
            }
            
            // Don't go past today
            if currentDate >= endDate { break }
        }
        
        // Add some June activity for monthly comparison
        let juneStart = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15))!
        pastStreaks.append(createStreak(start: juneStart, length: 4))
        
        let juneLaterStart = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 25))!
        pastStreaks.append(createStreak(start: juneLaterStart, length: 2))
        
        // Current streak started recently in July (this month)
        let currentStart = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 1))!
        
        return StreakData(
            currentStartDate: currentStart,
            pastStreaks: pastStreaks,
            isActiveStreak: true
        )
    }
    
    private func generateSteadyProgressData(from startDate: Date, to endDate: Date) -> StreakData {
        var pastStreaks: [Streak] = []
        var currentDate = startDate
        
        // Progressive improvement pattern
        let streakLengths = [5, 8, 3, 15, 6, 24, 12, 35, 8, 52, 18]
        
        for length in streakLengths {
            pastStreaks.append(createStreak(start: currentDate, length: length))
            currentDate = Calendar.current.date(byAdding: .day, value: length + Int.random(in: 3...10), to: currentDate)!
            
            if currentDate >= endDate { break }
        }
        
        // Add June streak for monthly data
        let juneStart = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10))!
        pastStreaks.append(createStreak(start: juneStart, length: 15))
        
        // Current streak started in mid-June, continuing into July
        let currentStart = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 28))!
        
        return StreakData(
            currentStartDate: currentStart,
            pastStreaks: pastStreaks,
            isActiveStreak: true
        )
    }
    
    private func generatePerfectRecordData(from startDate: Date, to endDate: Date) -> StreakData {
        // One perfect streak from January 1st to today
        return StreakData(
            currentStartDate: startDate,
            pastStreaks: [],
            isActiveStreak: true
        )
    }
    
    private func generateRecentSetbackData(from startDate: Date, to endDate: Date) -> StreakData {
        var pastStreaks: [Streak] = []
        var currentDate = startDate
        
        // A few early attempts
        pastStreaks.append(createStreak(start: currentDate, length: 8))
        currentDate = Calendar.current.date(byAdding: .day, value: 12, to: currentDate)!
        
        pastStreaks.append(createStreak(start: currentDate, length: 23))
        currentDate = Calendar.current.date(byAdding: .day, value: 28, to: currentDate)!
        
        // Long successful streak (most of the year)
        let longStreakStart = currentDate
        let longStreakEnd = Calendar.current.date(byAdding: .day, value: -10, to: endDate)!
        let longStreakLength = Calendar.current.dateComponents([.day], from: longStreakStart, to: longStreakEnd).day ?? 120
        
        pastStreaks.append(Streak(
            id: UUID(),
            startDate: longStreakStart,
            endDate: longStreakEnd,
            length: longStreakLength
        ))
        
        // Current streak started recently after setback in July
        let currentStart = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 1))!
        
        return StreakData(
            currentStartDate: currentStart,
            pastStreaks: pastStreaks,
            isActiveStreak: true
        )
    }
    
    // MARK: - Helper Methods
    
    private func createStreak(start: Date, length: Int) -> Streak {
        let end = Calendar.current.date(byAdding: .day, value: length, to: start)!
        return Streak(
            id: UUID(),
            startDate: start,
            endDate: end,
            length: length
        )
    }
    
    // MARK: - Data Management
    
    func applyDummyData(scenario: DummyDataScenario, to viewModel: DayCounterViewModel) {
        let dummyData = generateDummyData(scenario: scenario)
        viewModel.streakData = dummyData
        viewModel.resetMilestoneTracking()
        isDummyDataActive = true
        viewModel.save()
        
        print("🎭 Applied dummy data scenario: \(scenario.rawValue)")
        print("   - Current streak: \(viewModel.currentStreak) days")
        print("   - Past streaks: \(dummyData.pastStreaks.count)")
        print("   - Total sober days: \(viewModel.totalSoberDays)")
        print("   - Longest streak: \(viewModel.longestStreak)")
    }
    
    func restoreRealData(to viewModel: DayCounterViewModel) {
        // Clear dummy data flag
        isDummyDataActive = false
        
        // Clear the dummy data UserDefaults key explicitly
        UserDefaults.standard.removeObject(forKey: dummyDataActiveKey)
        
        // Reset to fresh state - this will force the app to show the initial setup
        viewModel.resetAllData()
        
        // Reset milestone tracking to ensure no dummy milestone state persists
        viewModel.resetMilestoneTracking()
        
        // Reset DateProvider in case dummy data used time offset
        #if DEBUG
        DateProvider.reset()
        #endif
        
        print("🔄 Restored real data - app reset to initial state")
        print("   - Dummy data flag cleared")
        print("   - Milestone tracking reset")
        print("   - DateProvider reset")
    }
    
    // MARK: - Statistics for Screenshots
    
    func getScenarioStats(scenario: DummyDataScenario) -> (currentStreak: Int, totalDays: Int, longestStreak: Int, attempts: Int) {
        let dummyData = generateDummyData(scenario: scenario)
        let tempViewModel = DayCounterViewModel()
        tempViewModel.streakData = dummyData
        
        return (
            currentStreak: tempViewModel.currentStreak,
            totalDays: tempViewModel.totalSoberDays,
            longestStreak: tempViewModel.longestStreak,
            attempts: tempViewModel.totalAttempts
        )
    }
}
#endif