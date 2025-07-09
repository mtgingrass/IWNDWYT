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
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Data")
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    print("🔍 Export Data HStack tapped!")
                    performDirectExport()
                }
                
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import Data")
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
                    Label("Reset All Data", systemImage: "trash")
                }
            } header: {
                Text("Data Management")
            } footer: {
                Text("Export your data for backup or transfer to another device. Reset will permanently delete all your progress.")
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
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
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
