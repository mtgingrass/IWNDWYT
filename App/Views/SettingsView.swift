//
//  SettingsView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @State private var showResetConfirmation = false
    @State private var showingDataManagement = false
    @State private var showingImportPicker = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettingsViewModel
    
    #if DEBUG
    @State private var showingDebugPanel = false
    #endif
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text(NSLocalizedString("settings_export_data", comment: "Export data button"))
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    print("🔍 Export Data HStack tapped!")
                    performDirectExport()
                }
                
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text(NSLocalizedString("settings_import_data", comment: "Import data button"))
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    print("🔍 Import Data HStack tapped!")
                    showingImportPicker = true
                }
                
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label(NSLocalizedString("alert_reset_data_title", comment: "Reset all data button"), systemImage: "trash")
                }
            } header: {
                Text(NSLocalizedString("header_data_management", comment: "Data management section header"))
            } footer: {
                Text(NSLocalizedString("settings_data_export_desc", comment: "Data export description"))
            }
            
            Section {
                Link(destination: URL(string: "https://www.reddit.com/r/stopdrinking/")!) {
                    Label("r/stopdrinking", systemImage: "link")
                }
            } header: {
                Text(NSLocalizedString("header_resources", comment: "Resources section header"))
            }
            Section {
                Toggle(isOn: $settings.motivationalNotificationsEnabled) {
                    Label(NSLocalizedString("settings_motivational_reminders", comment: "Motivational reminders toggle"), systemImage: "bell")
                }
                
                if settings.motivationalNotificationsEnabled {
                    NotificationPermissionView()
                }
            } header: {
                Text(NSLocalizedString("header_notifications", comment: "Notifications section header"))
            } footer: {
                Text(NSLocalizedString("settings_notifications_desc", comment: "Notifications description"))
            }
            Section {
                Button {
                    RatingManager.shared.forceRatingRequest()
                } label: {
                    Label(NSLocalizedString("settings_rate_app", comment: "Rate app button"), systemImage: "star")
                }
                
                Link(destination: URL(string: "mailto:iwndwytoday@markgingrass.com")!) {
                    Label(NSLocalizedString("settings_contact_support", comment: "Contact support button"), systemImage: "envelope")
                }
                NavigationLink {
                    AboutView()
                } label: {
                    Label(NSLocalizedString("nav_about", comment: "About button"), systemImage: "info.circle")
                }
                
                #if DEBUG
                Button("Open Debug Panel") {
                    showingDebugPanel = true
                }
                #endif
            } header: {
                Text(NSLocalizedString("header_support", comment: "Support section header"))
            }
        }
        .navigationTitle(NSLocalizedString("nav_settings", comment: "Settings navigation title"))
        .alert(NSLocalizedString("alert_reset_data_title", comment: "Reset alert title"), isPresented: $showResetConfirmation) {
            Button(NSLocalizedString("btn_cancel", comment: "Cancel button"), role: .cancel) { }
            Button(NSLocalizedString("action_reset", comment: "Reset button"), role: .destructive) {
                viewModel.resetAllData()
                dismiss()
            }
        } message: {
            Text(NSLocalizedString("settings_reset_confirm", comment: "Reset confirmation message"))
        }
        .sheet(isPresented: $showingDataManagement) {
            DataImportExportView()
                .environmentObject(viewModel)
                .onAppear {
                    print("🔍 Sheet content appeared")
                }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImportSelection(result)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button(NSLocalizedString("btn_ok", comment: "OK button")) { }
        } message: {
            Text(alertMessage)
        }
        
        #if DEBUG
        .sheet(isPresented: $showingDebugPanel) {
            DebugPanelView()
                .environmentObject(viewModel)
                .environmentObject(settings)
        }
        #endif
    }
    
    private func performDirectExport() {
        let result = viewModel.exportData()
        
        switch result {
        case .success(let url):
            presentActivityViewController(with: url)
            // No success alert - the share sheet appearance is confirmation enough
            
        case .failure(let error):
            alertTitle = "Export Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func presentActivityViewController(with url: URL) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                return
            }
            
            // Find the topmost presented view controller
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            // For iPad compatibility
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = topViewController.view
                popoverController.sourceRect = CGRect(x: topViewController.view.bounds.midX, y: topViewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            topViewController.present(activityViewController, animated: true)
        }
    }
    
    private func handleImportSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing the security-scoped resource
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            let importResult = viewModel.importData(from: url)
            switch importResult {
            case .success(let message):
                alertTitle = "Import Complete"
                alertMessage = message
                showingAlert = true
                
            case .failure(let error):
                alertTitle = "Import Failed"
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            
        case .failure(let error):
            alertTitle = "File Selection Error"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
                Button(NSLocalizedString("settings_open_settings", comment: "Open settings button")) {
                    settings.openSystemSettings()
                }
                .font(.footnote)
                .foregroundColor(.blue)
            } else if settings.notificationPermissionStatus == .notDetermined {
                Button(NSLocalizedString("settings_request_permission", comment: "Request permission button")) {
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
