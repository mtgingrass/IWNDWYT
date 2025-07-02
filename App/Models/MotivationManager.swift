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
        "Today's a good day to begin again.",
        "You owe it to yourself to try.",
        "Start small. Start now.",
        "You don't have to be perfect—just start.",
        "The first step is the hardest. Take it today.",
        "You're stronger than this habit.",
        "Your future self will thank you.",
        "This is your reset button. Tap it.",
        "Every streak starts with Day One.",
        "Change begins the moment you decide.",
        "You deserve a life free from this cycle.",
        "Nothing changes if nothing changes.",
        "Start now. Not later. Now.",
        "Let this be the last time you restart.",
        "You're not alone in this. Start fresh.",
        "One day can turn into many.",
        "Progress beats perfection.",
        "You've waited long enough. Begin.",
        "This moment is your turning point.",
        "Make today count for something bigger."
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
            content.title = "IWNDWYT"
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
                .filter { $0.hasPrefix("motivation_notif_") || $0 == "dailyMotivation" }
            
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
        
        let message = motivationMessages.randomElement() ?? "You've got this. Start today."
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
            let message = self.motivationMessages.randomElement() ?? "Test notification"
            let content = UNMutableNotificationContent()
            content.title = "IWNDWYT"
            content.subtitle = message
            content.body = "Tap for motivation"
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
            let message = self.motivationMessages.randomElement() ?? "Test notification"
            content.title = "IWNDWYT"
            content.subtitle = message
            content.body = "Quick test - tap for motivation"
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
        return motivationMessages.randomElement() ?? "You've got this. Start today."
    }
}
