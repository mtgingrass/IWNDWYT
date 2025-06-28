//
//  AboutView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

// Leave the imports and other parts unchanged
import SwiftUI

struct AboutView: View {
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
                // App Icon and Name
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Image("AppIconLarge")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(20)
                            .shadow(radius: 5)

                        Text("IWNDWYToday")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }

                    Text("I Will Not Destruct With You Today")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // App Description
                VStack(alignment: .leading, spacing: 12) {
                    Text("Designed to stop habits, track progress with milestones, and stay motivated.")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("Start with getting through just one day.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Features
                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(icon: "calendar", text: "Track daily progress")
                    FeatureRow(icon: "chart.bar.fill", text: "View statistics and metrics")
                    FeatureRow(icon: "flame.fill", text: "Celebrate milestones")
                    FeatureRow(icon: "iphone", text: "Simple, intuitive interface")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // Acknowledgments
                VStack(alignment: .leading, spacing: 12) {
                    Text("Acknowledgments")
                        .font(.headline)

                    Text("Inspired by the community at r/stopdrinking and the daily commitment shared by millions.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Developer Contact
                VStack(alignment: .leading, spacing: 12) {
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

                VStack(spacing: 12) {
                    NavigationLink(destination: TipJarView()) {
                        Text("💙 Leave a Tip")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .stroke(Color.blue, lineWidth: 1.5)
                                    .shadow(color: Color.blue.opacity(0.2), radius: 2, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Text("Version \(appVersion) • Build \(buildNumber) • iOS \(minimumOSVersion)+")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Text("© 2025 Mark Gingrass")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
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
