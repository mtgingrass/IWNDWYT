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
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(DayCounterViewModel.shared)
                .environmentObject(settings)
                .preferredColorScheme(.light)
        }
    }
}
