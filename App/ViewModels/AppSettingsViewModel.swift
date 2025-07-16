import SwiftUI
import UserNotifications

class AppSettingsViewModel: ObservableObject {
    static let shared = AppSettingsViewModel()
    
    @AppStorage("hasChosenStartDate") var hasChosenStartDate = false
    @AppStorage("motivationalNotificationsEnabled") var motivationalNotificationsEnabled: Bool = true {
        didSet {
            if motivationalNotificationsEnabled {
                checkNotificationPermission()
                MotivationManager.shared.scheduleMotivationalNotifications()
            } else {
                MotivationManager.shared.cancelAllNotifications()
            }
        }
    }
    
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined

    // Always use light mode
    let colorScheme: ColorScheme = .light

    func markStartDateChosen() {
        hasChosenStartDate = true
        // Check if there's an active streak to determine notification scheduling
        let isActiveStreak = DayCounterViewModel.shared.isActiveStreak
        if isActiveStreak {
            let currentDay = DayCounterViewModel.shared.currentStreak
            MotivationManager.shared.scheduleStreakEncouragementIfNeeded(
                streakActive: true,
                currentStreakDay: currentDay
            )
        } else {
            MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: false)
        }
    }

    func resetStartDateFlag() {
        hasChosenStartDate = false
        // Check if there's an active streak to determine notification scheduling
        let isActiveStreak = DayCounterViewModel.shared.isActiveStreak
        if isActiveStreak {
            let currentDay = DayCounterViewModel.shared.currentStreak
            MotivationManager.shared.scheduleStreakEncouragementIfNeeded(
                streakActive: true,
                currentStreakDay: currentDay
            )
        } else {
            MotivationManager.shared.scheduleDailyMotivationIfNeeded(streakStarted: false)
        }
    }
    
    func checkNotificationPermission() {
        MotivationManager.shared.checkNotificationPermission { [weak self] status in
            self?.notificationPermissionStatus = status
        }
    }
    
    func requestNotificationPermission() {
        MotivationManager.shared.requestNotificationPermission()
        // Check again after requesting
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.checkNotificationPermission()
        }
    }
    
    func openSystemSettings() {
        MotivationManager.shared.openSystemSettings()
    }
}
