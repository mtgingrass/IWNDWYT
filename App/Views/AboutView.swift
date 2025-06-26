//
//  AboutView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct AboutView: View {
    // Computed properties to get app metadata
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    private var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? 
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "IWNDWYT"
    }
    
    private var minimumOSVersion: String {
        Bundle.main.infoDictionary?["MinimumOSVersion"] as? String ?? "17.0"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Icon and Name Section
                VStack(spacing: 16) {
                    // You can replace this with your actual app icon
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    
                    Text("IWNDWYToday")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("I Will Not Destruct With You Today")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Divider()
                
                // App Description
                VStack(alignment: .leading, spacing: 12) {
                    Text("About This App")
                        .font(.headline)
                    
                    Text("IWNDWYToday is a habit breaking app designed to stop habits one day at a time. Track progress, celebrate milestones, and stay motivated.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // Version Information
                VStack(spacing: 12) {
                    InfoRow(title: "Version", value: appVersion)
                    InfoRow(title: "Build", value: buildNumber)
                    InfoRow(title: "Platform", value: "iOS \(minimumOSVersion)+")
                }
                
                Divider()
                
                // Developer Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Developer")
                        .font(.headline)
                    
                    InfoRow(title: "Created by", value: "Mark Gingrass")
                    
                    HStack {
                        Text("Contact:")
                            .foregroundColor(.primary)
                        Spacer()
                        Link("iwndwytoday@markgingrass.com", destination: URL(string: "mailto:iwndwytoday@markgingrass.com")!)
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // Features
                VStack(alignment: .leading, spacing: 12) {
                    Text("Features")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "calendar", text: "Track daily progress")
                        FeatureRow(icon: "chart.bar.fill", text: "View detailed statistics and metrics")
                        FeatureRow(icon: "flame.fill", text: "Celebrate streak milestones")
                        FeatureRow(icon: "iphone", text: "Simple, intuitive interface")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // Acknowledgments
                VStack(alignment: .leading, spacing: 12) {
                    Text("Acknowledgments")
                        .font(.headline)
                    
                    Text("This app is inspired by the supportive community at r/stopdrinking and the daily commitment shared by millions: \"I Will Not Drink With You Today.\"")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Special thanks to all those who have stopped bad habits - you inspire others every day.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // Copyright
                VStack(spacing: 8) {
                    Text("© 2025 Mark Gingrass")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Like this App, leave a tip for the develper.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 20)
            Text(text)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
} 
