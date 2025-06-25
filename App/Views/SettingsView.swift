//
//  SettingsView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = DayCounterViewModel()
    @State private var showResetConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
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
                Link(destination: URL(string: "mailto:iwndwyt@markgingrass.com")!) {
                    Label("Contact Support", systemImage: "envelope")
                }
                NavigationLink {
                    Text("Version 1.0.0")
                        .navigationTitle("About")
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
                resetAllData()
            }
        } message: {
            Text("Are you sure you want to reset all data? This action cannot be undone.")
        }
    }
    
    private func resetAllData() {
        // Clear UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Initialize fresh data
        viewModel.sobrietyData = SobrietyData(currentStartDate: DateProvider.now, pastStreaks: [])
        viewModel.save()
        
        // Optionally dismiss the settings screen after reset
        dismiss()
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
} 
