//
//  IWNDWYTApp.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

@main
struct IWNDWYTApp: App {
    @StateObject private var settings = AppSettingsViewModel.shared
    @StateObject private var sessionTracker = SessionTracker()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            MainTabView() // or ContentView(...) if that's your root
                .environmentObject(DayCounterViewModel.shared)
                .environmentObject(settings)
                .environmentObject(sessionTracker) // ✅ Inject here
                .preferredColorScheme(.light)
        }
        .onChange(of: scenePhase) {
            sessionTracker.handleScenePhaseChange(to: scenePhase)
        }
    }
}
