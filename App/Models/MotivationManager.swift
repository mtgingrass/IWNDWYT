//
//  MotivationManager.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import Foundation
import UserNotifications
import UIKit

class MotivationManager {
    static let shared = MotivationManager()

    #if DEBUG
    // Debug scheduling time - can be modified from Debug Panel
    static var debugNotificationHour: Int = 9
    static var debugNotificationMinute: Int = 0
    #endif

    private let motivationMessages = [
        NSLocalizedString("motivation_1", comment: "Motivational message 1"),
        NSLocalizedString("motivation_2", comment: "Motivational message 2"),
        NSLocalizedString("motivation_3", comment: "Motivational message 3"),
        NSLocalizedString("motivation_4", comment: "Motivational message 4"),
        NSLocalizedString("motivation_5", comment: "Motivational message 5"),
        NSLocalizedString("motivation_6", comment: "Motivational message 6"),
        NSLocalizedString("motivation_7", comment: "Motivational message 7"),
        NSLocalizedString("motivation_8", comment: "Motivational message 8"),
        NSLocalizedString("motivation_9", comment: "Motivational message 9"),
        NSLocalizedString("motivation_10", comment: "Motivational message 10"),
        NSLocalizedString("motivation_11", comment: "Motivational message 11"),
        NSLocalizedString("motivation_12", comment: "Motivational message 12"),
        NSLocalizedString("motivation_13", comment: "Motivational message 13"),
        NSLocalizedString("motivation_14", comment: "Motivational message 14"),
        NSLocalizedString("motivation_15", comment: "Motivational message 15"),
        NSLocalizedString("motivation_16", comment: "Motivational message 16"),
        NSLocalizedString("motivation_17", comment: "Motivational message 17"),
        NSLocalizedString("motivation_18", comment: "Motivational message 18"),
        NSLocalizedString("motivation_19", comment: "Motivational message 19"),
        NSLocalizedString("motivation_20", comment: "Motivational message 20")
    ]
    
    private let encouragementMessages = [
        NSLocalizedString("encouragement_1", comment: "Encouragement message 1"),
        NSLocalizedString("encouragement_2", comment: "Encouragement message 2"),
        NSLocalizedString("encouragement_3", comment: "Encouragement message 3"),
        NSLocalizedString("encouragement_4", comment: "Encouragement message 4"),
        NSLocalizedString("encouragement_5", comment: "Encouragement message 5"),
        NSLocalizedString("encouragement_6", comment: "Encouragement message 6"),
        NSLocalizedString("encouragement_7", comment: "Encouragement message 7"),
        NSLocalizedString("encouragement_8", comment: "Encouragement message 8"),
        NSLocalizedString("encouragement_9", comment: "Encouragement message 9"),
        NSLocalizedString("encouragement_10", comment: "Encouragement message 10"),
        NSLocalizedString("encouragement_11", comment: "Encouragement message 11"),
        NSLocalizedString("encouragement_12", comment: "Encouragement message 12"),
        NSLocalizedString("encouragement_13", comment: "Encouragement message 13"),
        NSLocalizedString("encouragement_14", comment: "Encouragement message 14"),
        NSLocalizedString("encouragement_15", comment: "Encouragement message 15")
    ]

    private init() {}

    #if DEBUG
    private func getNotificationTime() -> (hour: Int, minute: Int) {
        return (MotivationManager.debugNotificationHour, MotivationManager.debugNotificationMinute)
    }
    #else
    private func getNotificationTime() -> (hour: Int, minute: Int) {
        return (9, 0) // Always 9:00 AM in release
    }
    #endif

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            print("Notification permission granted: \(granted)")
        }
    }
    
    func checkNotificationPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    func openSystemSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func scheduleMotivationalNotifications() {
        checkNotificationPermission { [weak self] status in
            switch status {
            case .authorized, .provisional, .ephemeral:
                self?.scheduleNotifications()
            case .denied, .notDetermined:
                print("Notifications not authorized. Status: \(status.rawValue)")
            @unknown default:
                print("Unknown notification authorization status")
            }
        }
    }
    
    private func scheduleNotifications() {
        cancelAllNotifications()

        let center = UNUserNotificationCenter.current()
        var dateComponents = DateComponents()
        let notificationTime = getNotificationTime()
        dateComponents.hour = notificationTime.hour
        dateComponents.minute = notificationTime.minute
        
        #if DEBUG
        // In debug mode, use the current date with the debug time
        var triggerDate = Calendar.current.date(from: dateComponents) ?? Date()
        
        // If the debug time has already passed today, schedule for tomorrow
        if triggerDate < DateProvider.now {
            triggerDate = Calendar.current.date(byAdding: .day, value: 1, to: triggerDate) ?? Date()
        }
        #else
        var triggerDate = Calendar.current.date(from: dateComponents) ?? Date()
        
        if triggerDate < Date() {
            triggerDate = Calendar.current.date(byAdding: .day, value: 1, to: triggerDate) ?? Date()
        }
        #endif

        for (index, message) in motivationMessages.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("notification_title", comment: "Notification title")
            content.body = message
            content.sound = .default
            content.badge = NSNumber(value: index + 1)

            guard let notificationDate = Calendar.current.date(byAdding: .day, value: index, to: triggerDate) else { continue }
            let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)

            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "motivation_notif_\(index)", content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("✅ Scheduled notification \(index) for: \(notificationDate)")
                }
            }
        }
    }

    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let allNotificationIdentifiers = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix("motivation_notif_") || $0 == "dailyMotivation" || $0 == "dailyEncouragement" }
            
            if !allNotificationIdentifiers.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: allNotificationIdentifiers)
                print("🗑️ Cancelled \(allNotificationIdentifiers.count) notifications: \(allNotificationIdentifiers)")
            } else {
                print("🗑️ No motivation notifications to cancel")
            }
        }
    }

    /// Schedules a single daily motivational notification at specified time if streak hasn't started. Cancels if streak started.
    func scheduleDailyMotivationIfNeeded(streakStarted: Bool) {
        print("🔔 scheduleDailyMotivationIfNeeded called with streakStarted: \(streakStarted)")
        
        let center = UNUserNotificationCenter.current()
        if streakStarted {
            print("🔔 Streak started - cancelling daily motivation")
            center.removePendingNotificationRequests(withIdentifiers: ["dailyMotivation"])
            return
        }
        
        // First, cancel any existing daily motivation
        center.removePendingNotificationRequests(withIdentifiers: ["dailyMotivation"])
        
        let message = motivationMessages.randomElement() ?? NSLocalizedString("notification_fallback", comment: "Fallback notification message")
        let content = UNMutableNotificationContent()
        content.title = "IWNDWYT"
        content.body = message
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        var dateComponents = DateComponents()
        let notificationTime = getNotificationTime()
        dateComponents.hour = notificationTime.hour
        dateComponents.minute = notificationTime.minute
        
        print("🔔 Debug notification time: \(notificationTime.hour):\(notificationTime.minute)")
        
        #if DEBUG
        // In debug mode, use DateProvider.now instead of Date()
        let currentDate = DateProvider.now
        print("🔔 Current debug date: \(currentDate)")
        
        // Create the trigger date for today using current debug date
        let calendar = Calendar.current
        var triggerComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        triggerComponents.hour = notificationTime.hour
        triggerComponents.minute = notificationTime.minute
        
        guard let triggerDate = calendar.date(from: triggerComponents) else {
            print("❌ Could not create trigger date")
            return
        }
        
        print("🔔 Initial trigger date: \(triggerDate)")
        
        // If the time has already passed today, schedule for tomorrow
        let finalTriggerDate: Date
        if triggerDate <= currentDate {
            finalTriggerDate = calendar.date(byAdding: .day, value: 1, to: triggerDate) ?? triggerDate
            print("🔔 Time passed today, scheduling for tomorrow: \(finalTriggerDate)")
        } else {
            finalTriggerDate = triggerDate
            print("🔔 Time is in future, scheduling for today: \(finalTriggerDate)")
        }
        
        // Create final trigger components
        let finalTriggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: finalTriggerDate)
        
        #else
        // Release mode - use normal Date()
        var triggerDate = Calendar.current.date(from: dateComponents) ?? Date()
        
        // If the time has already passed today, schedule for tomorrow
        if triggerDate < Date() {
            triggerDate = Calendar.current.date(byAdding: .day, value: 1, to: triggerDate) ?? Date()
            print("🔔 Time passed today, scheduling for tomorrow: \(triggerDate)")
        } else {
            print("🔔 Time is in future, scheduling for today: \(triggerDate)")
        }
        
        let finalTriggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        #endif
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: finalTriggerComponents, repeats: true)
        
        print("🔔 Final trigger components: \(finalTriggerComponents)")
        print("🔔 Trigger next fire date: \(trigger.nextTriggerDate() ?? Date())")
        
        let request = UNNotificationRequest(
            identifier: "dailyMotivation",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                #if DEBUG
                print("✅ Daily motivation scheduled for: \(finalTriggerDate)")
                #else
                print("✅ Daily motivation scheduled for: \(triggerDate)")
                #endif
            }
        }
    }

    #if DEBUG
    /// Test method to schedule a notification for testing purposes
    func scheduleTestNotification(minutesFromNow: Int = 1) {
        print("🧪 Scheduling test notification for \(minutesFromNow) minute(s) from now")
        
        // First check permissions
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("🔍 Test notification permission status: \(settings.authorizationStatus.rawValue)")
            
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                print("❌ Test notification failed: Not authorized")
                return
            }
            
            let center = UNUserNotificationCenter.current()
            let message = self.motivationMessages.randomElement() ?? NSLocalizedString("notification_test", comment: "Test notification message")
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("notification_title", comment: "Notification title")
            content.subtitle = message
            content.body = NSLocalizedString("notification_tap_motivation", comment: "Notification body text")
            content.sound = .default
            content.badge = NSNumber(value: 1)
            
            let timeInterval = TimeInterval(minutesFromNow * 60)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            
            // Use unique identifier with timestamp
            let identifier = "testNotification_\(Date().timeIntervalSince1970)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Failed to schedule test notification: \(error.localizedDescription)")
                } else {
                    let fireTime = Date().addingTimeInterval(timeInterval)
                    print("✅ Test notification scheduled for \(minutesFromNow) minute(s) from now")
                    print("✅ Will fire at: \(DateFormatter.localizedString(from: fireTime, dateStyle: .none, timeStyle: .medium))")
                    print("✅ Identifier: \(identifier)")
                }
            }
        }
    }
    
    /// Schedule a debug notification that respects the DateProvider offset
    func scheduleDebugNotification(secondsFromNow: Int = 30) {
        let timeInterval = max(1, secondsFromNow) // Ensure minimum 1 second
        print("🧪 Scheduling debug notification for \(timeInterval) second(s) from now")
        
        // First check permissions
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("🔍 Debug notification permission status: \(settings.authorizationStatus.rawValue)")
            
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                print("❌ Debug notification failed: Not authorized")
                return
            }
            
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            let message = self.motivationMessages.randomElement() ?? NSLocalizedString("notification_test", comment: "Test notification message")
            content.title = NSLocalizedString("notification_title", comment: "Notification title")
            content.subtitle = message
            content.body = NSLocalizedString("notification_quick_test", comment: "Quick test notification body")
            content.sound = .default
            content.badge = NSNumber(value: 1)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: false)
            
            // Use unique identifier with timestamp
            let identifier = "debugNotification_\(Date().timeIntervalSince1970)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Failed to schedule debug notification: \(error.localizedDescription)")
                } else {
                    let fireTime = Date().addingTimeInterval(TimeInterval(timeInterval))
                    print("✅ Debug notification scheduled for \(timeInterval) seconds from now")
                    print("✅ Will fire at: \(DateFormatter.localizedString(from: fireTime, dateStyle: .none, timeStyle: .medium))")
                    print("✅ Identifier: \(identifier)")
                }
            }
        }
    }
    
    /// Cancel all test and debug notifications
    func cancelTestNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["testNotification", "debugNotification"])
        print("🗑️ Cancelled test notifications")
    }
    
    /// Debug method to list all pending notifications
    func listPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📋 Pending notifications (\(requests.count)):")
            for request in requests {
                var triggerInfo = "Unknown trigger"
                if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger {
                    triggerInfo = "Calendar: \(calendarTrigger.nextTriggerDate() ?? Date())"
                } else if let intervalTrigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    triggerInfo = "Interval: \(intervalTrigger.timeInterval)s"
                }
                print("  - \(request.identifier): \(triggerInfo)")
            }
        }
    }
    #endif
    
    /// Get a random motivational message for popups
    func getRandomMotivationalMessage() -> String {
        return motivationMessages.randomElement() ?? NSLocalizedString("notification_fallback", comment: "Fallback notification message")
    }
    
    /// Schedule daily encouragement notifications when user is in an active streak
    func scheduleStreakEncouragementIfNeeded(streakActive: Bool, currentStreakDay: Int = 0) {
        print("🎯 scheduleStreakEncouragementIfNeeded called with streakActive: \(streakActive), day: \(currentStreakDay)")
        
        let center = UNUserNotificationCenter.current()
        
        // Cancel any existing encouragement notifications
        center.removePendingNotificationRequests(withIdentifiers: ["dailyEncouragement"])
        
        // Only schedule if streak is active
        guard streakActive else {
            print("🎯 No active streak - not scheduling encouragement")
            return
        }
        
        // Check permissions first
        checkNotificationPermission { [weak self] status in
            guard status == .authorized || status == .provisional else {
                print("❌ Encouragement notification failed: Not authorized")
                return
            }
            
            self?.scheduleEncouragementNotification(currentStreakDay: currentStreakDay)
        }
    }
    
    private func scheduleEncouragementNotification(currentStreakDay: Int) {
        let center = UNUserNotificationCenter.current()
        
        // Choose message based on milestone or random encouragement
        let message: String
        let title = NSLocalizedString("notification_encouragement_title", comment: "Encouragement notification title")
        
        // Check for milestone messages
        switch currentStreakDay {
        case 7:
            message = NSLocalizedString("milestone_week", comment: "One week milestone")
        case 30:
            message = NSLocalizedString("milestone_month", comment: "30 day milestone")
        case 100:
            message = NSLocalizedString("milestone_100", comment: "100 day milestone")
        case 365:
            message = NSLocalizedString("milestone_year", comment: "One year milestone")
        default:
            // Use regular encouragement with day count
            let randomEncouragement = encouragementMessages.randomElement() ?? NSLocalizedString("encouragement_1", comment: "Default encouragement")
            message = String(format: randomEncouragement, currentStreakDay)
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        var dateComponents = DateComponents()
        let notificationTime = getNotificationTime()
        dateComponents.hour = notificationTime.hour
        dateComponents.minute = notificationTime.minute
        
        print("🎯 Scheduling encouragement for \(notificationTime.hour):\(notificationTime.minute)")
        
        #if DEBUG
        // In debug mode, use DateProvider.now
        let currentDate = DateProvider.now
        let calendar = Calendar.current
        var triggerComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        triggerComponents.hour = notificationTime.hour
        triggerComponents.minute = notificationTime.minute
        
        guard let triggerDate = calendar.date(from: triggerComponents) else {
            print("❌ Could not create trigger date")
            return
        }
        
        let finalTriggerDate: Date
        if triggerDate <= currentDate {
            finalTriggerDate = calendar.date(byAdding: .day, value: 1, to: triggerDate) ?? triggerDate
            print("🎯 Time passed today, scheduling for tomorrow: \(finalTriggerDate)")
        } else {
            finalTriggerDate = triggerDate
            print("🎯 Time is in future, scheduling for today: \(finalTriggerDate)")
        }
        
        let finalTriggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: finalTriggerDate)
        #else
        // Release mode - use normal Date()
        var triggerDate = Calendar.current.date(from: dateComponents) ?? Date()
        
        if triggerDate < Date() {
            triggerDate = Calendar.current.date(byAdding: .day, value: 1, to: triggerDate) ?? Date()
        }
        
        let finalTriggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        #endif
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: finalTriggerComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "dailyEncouragement",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule encouragement: \(error.localizedDescription)")
            } else {
                print("✅ Daily encouragement scheduled with message: \(message)")
            }
        }
    }
}
