
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

                        Text(NSLocalizedString("about_app_name", comment: "App name"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }

                    Text(NSLocalizedString("about_app_full_name", comment: "App full name"))
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // App Description
                VStack(alignment: .leading, spacing: 12) {
                    Text(NSLocalizedString("about_app_description", comment: "App description"))
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text(NSLocalizedString("about_app_tagline", comment: "App tagline"))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Features
                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(icon: "calendar", text: NSLocalizedString("about_feature_track", comment: "Track daily progress feature"))
                    FeatureRow(icon: "chart.bar.fill", text: NSLocalizedString("about_feature_stats", comment: "View statistics feature"))
                    FeatureRow(icon: "flame.fill", text: NSLocalizedString("about_feature_milestones", comment: "Celebrate milestones feature"))
                    FeatureRow(icon: "iphone", text: NSLocalizedString("about_feature_interface", comment: "Simple interface feature"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // Acknowledgments
                VStack(alignment: .leading, spacing: 12) {
                    Text(NSLocalizedString("about_acknowledgments", comment: "Acknowledgments section title"))
                        .font(.headline)

                    Text(NSLocalizedString("about_inspiration", comment: "Inspiration text"))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Developer Contact
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(NSLocalizedString("about_contact", comment: "Contact label"))
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
                        Text(NSLocalizedString("about_leave_tip", comment: "Leave a tip button"))
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

                    Text(String(format: NSLocalizedString("about_version_format", comment: "Version format string"), appVersion, buildNumber, minimumOSVersion))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Text(NSLocalizedString("about_copyright", comment: "Copyright text"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .navigationTitle(NSLocalizedString("nav_about", comment: "About navigation title"))
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
