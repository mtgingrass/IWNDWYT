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
        
        var triggerDate = Calendar.current.date(from: dateComponents) ?? Date()
        
        if triggerDate < Date() {
            triggerDate = Calendar.current.date(byAdding: .day, value: 1, to: triggerDate) ?? Date()
        }

        for (index, message) in motivationMessages.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "IWNDWYT"
            content.body = message
            content.sound = .default

            guard let notificationDate = Calendar.current.date(byAdding: .day, value: index, to: triggerDate) else { continue }
            let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)

            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "motivation_notif_\(index)", content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }

    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let motivationIdentifiers = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix("motivation_notif_") }
            
            if !motivationIdentifiers.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: motivationIdentifiers)
            }
        }
    }

    /// Schedules a single daily motivational notification at 9am if streak hasn't started. Cancels if streak started.
    func scheduleDailyMotivationIfNeeded(streakStarted: Bool) {
        let center = UNUserNotificationCenter.current()
        if streakStarted {
            center.removePendingNotificationRequests(withIdentifiers: ["dailyMotivation"])
            return
        }
        let message = motivationMessages.randomElement() ?? "You've got this. Start today."
        let content = UNMutableNotificationContent()
        content.title = "Motivation for Today"
        content.body = message
        content.sound = .default
        var dateComponents = DateComponents()
        let notificationTime = getNotificationTime()
        dateComponents.hour = notificationTime.hour
        dateComponents.minute = notificationTime.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "dailyMotivation",
            content: content,
            trigger: trigger
        )
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    #if DEBUG
    /// Test method to schedule a notification for testing purposes
    func scheduleTestNotification(minutesFromNow: Int = 1) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification from IWNDWYT"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutesFromNow * 60), repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled for \(minutesFromNow) minute(s) from now")
            }
        }
    }
    
    /// Cancel all test notifications
    func cancelTestNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["testNotification"])
    }
    #endif
} 