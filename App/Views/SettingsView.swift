//
//  SettingsView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @State private var showResetConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettingsViewModel
    
    var body: some View {
        List {
            Section {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Reset All Data", systemImage: "trash")
                }
            } header: {
                Text("Data Management")
            } footer: {
                Text("This will permanently delete all your progress, streaks, and records.")
            }
            
            Section {
                Link(destination: URL(string: "https://www.reddit.com/r/stopdrinking/")!) {
                    Label("r/stopdrinking", systemImage: "link")
                }
            } header: {
                Text("Resources")
            }
            Section {
                Toggle(isOn: $settings.motivationalNotificationsEnabled) {
                    Label("Motivational Reminders", systemImage: "bell")
                }
                
                if settings.motivationalNotificationsEnabled {
                    NotificationPermissionView()
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text("Receive daily motivational messages to help you stay on track.")
            }
            Section {
                Button {
                    RatingManager.shared.forceRatingRequest()
                } label: {
                    Label("Rate IWNDWYT", systemImage: "star")
                }
                
                Link(destination: URL(string: "mailto:iwndwytoday@markgingrass.com")!) {
                    Label("Contact Support", systemImage: "envelope")
                }
                NavigationLink {
                    AboutView()
                } label: {
                    Label("About", systemImage: "info.circle")
                }
            } header: {
                Text("Support")
            }
        }
        .navigationTitle("Settings")
        .alert("Reset All Data", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetAllData()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to reset all data? This action cannot be undone.")
        }
    }
}

struct NotificationPermissionView: View {
    @EnvironmentObject private var settings: AppSettingsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: permissionIcon)
                    .foregroundColor(permissionColor)
                Text(permissionText)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            if settings.notificationPermissionStatus == .denied {
                Button("Open Settings") {
                    settings.openSystemSettings()
                }
                .font(.footnote)
                .foregroundColor(.blue)
            } else if settings.notificationPermissionStatus == .notDetermined {
                Button("Request Permission") {
                    settings.requestNotificationPermission()
                }
                .font(.footnote)
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            settings.checkNotificationPermission()
        }
    }
    
    private var permissionIcon: String {
        switch settings.notificationPermissionStatus {
        case .authorized, .provisional, .ephemeral:
            return "checkmark.circle.fill"
        case .denied:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        @unknown default:
            return "questionmark.circle.fill"
        }
    }
    
    private var permissionColor: Color {
        switch settings.notificationPermissionStatus {
        case .authorized, .provisional, .ephemeral:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .orange
        }
    }
    
    private var permissionText: String {
        switch settings.notificationPermissionStatus {
        case .authorized, .provisional, .ephemeral:
            return "Notifications enabled"
        case .denied:
            return "Notifications disabled in system settings"
        case .notDetermined:
            return "Notification permission not determined"
        @unknown default:
            return "Unknown notification status"
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(DayCounterViewModel.shared)
            .environmentObject(AppSettingsViewModel.shared)
    }
} 
