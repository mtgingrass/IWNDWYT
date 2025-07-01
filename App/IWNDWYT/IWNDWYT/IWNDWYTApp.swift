//
//  IWNDWYTApp.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap when app is in background/closed
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Mark that we should show motivational popup
        NotificationCenter.default.post(name: .showMotivationalPopup, object: nil)
        completionHandler()
    }
}

// Notification name for showing motivational popup
extension Notification.Name {
    static let showMotivationalPopup = Notification.Name("showMotivationalPopup")
}

@main
struct IWNDWYTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var dayCounterViewModel = DayCounterViewModel.shared
    @StateObject private var appSettingsViewModel = AppSettingsViewModel.shared
    @StateObject private var sessionTracker = SessionTracker.shared
    @Environment(\.scenePhase) private var scenePhase

    init() {
        MotivationManager.shared.requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView() // or ContentView(...) if that's your root
                .environmentObject(DayCounterViewModel.shared)
                .environmentObject(appSettingsViewModel)
                .environmentObject(sessionTracker) // ✅ Inject here
                .preferredColorScheme(.light)
        }
        .onChange(of: scenePhase) {
            sessionTracker.handleScenePhaseChange(to: scenePhase)
        }
    }
}
