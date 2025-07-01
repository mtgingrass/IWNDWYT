//
//  IWNDWYTApp.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {}

@main
struct IWNDWYTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var dayCounterViewModel = DayCounterViewModel.shared
    @StateObject private var appSettingsViewModel = AppSettingsViewModel.shared
    @StateObject private var sessionTracker = SessionTracker()
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
