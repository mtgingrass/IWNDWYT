//
//  ContentView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

//
//  ContentView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @EnvironmentObject private var settings: AppSettingsViewModel
    @EnvironmentObject private var sessionTracker: SessionTracker
    @State private var showTipAlert = false
    
    @Binding var selectedTab: Int
    @Binding var showingSettings: Bool
    @State private var showEndConfirmation = false
    @State private var showCancelConfirmation = false
    @State private var animateProgressSection = false
    @State private var timeUntilMidnight: TimeInterval = 0
    @State private var navigateToStreakView = false
    @State private var navigateToTipJar = false
    
    @AppStorage("hasSeenIntro") private var hasSeenIntro: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private func updateTimeUntilMidnight() {
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.startOfDay(for: now.addingTimeInterval(24*60*60))
        timeUntilMidnight = tomorrow.timeIntervalSince(now)
    }
    
    private func formatTimeRemaining() -> String {
        let totalSeconds = Int(timeUntilMidnight)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        var components: [String] = []

        if hours > 0 {
            components.append("\(hours)h")
        }

        if minutes > 0 || hours > 0 {
            components.append("\(minutes)m")
        }

        components.append("\(seconds)s")

        return components.joined(separator: " ")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 10)

                // Header Button
                StreakActionButtonView(selectedTab: $selectedTab)

                ProgressSectionView()

                #if DEBUG
                NavigationLink("Open Debug Panel") {
                    DebugPanelView()
                }
                .font(.footnote)
                .padding(.top)
                #endif
            }
            NavigationLink(destination: TipJarView(), isActive: $navigateToTipJar) {
                EmptyView()
            }
            .hidden()
            .padding()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.4)) {
                animateProgressSection = true
            }
            updateTimeUntilMidnight()
        }
        .onReceive(timer) { _ in
            updateTimeUntilMidnight()
        }
        .sheet(isPresented: .constant(!hasSeenIntro)) {
            IntroView(hasSeenIntro: $hasSeenIntro)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 8) {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Image(systemName: "info.circle")
                            .imageScale(.medium)
                            .settingsButtonStyle()
                    }
                    
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .imageScale(.medium)
                            .settingsButtonStyle()
                    }
                }
            }
        }
        // 👉 Tip Jar trigger logic
            .onReceive(sessionTracker.$shouldShowTipPrompt) { shouldShow in
                if shouldShow {
                    showTipAlert = true
                }
            }
            .alert("Enjoying the app?", isPresented: $showTipAlert) {
                Button("Not Now", role: .cancel) {
                    sessionTracker.dismissTipPrompt()
                }
                Button("Tip the Developer") {
                    sessionTracker.dismissTipPrompt()
                    navigateToTipJar = true
                }
            } message: {
                Text("Hi, you've opened the app over \(sessionTracker.openCount) times. Consider leaving a tip if it’s helped you!")
            }
    }
}

#Preview {
    NavigationView {
        ContentView(selectedTab: .constant(0), showingSettings: .constant(false))
            .navigationBarTitle("IWNDWYT", displayMode: .inline)
    }
    .environmentObject(DayCounterViewModel.shared)
    .environmentObject(AppSettingsViewModel.shared)
    .environmentObject(SessionTracker()) // ✅ this was missing
    .preferredColorScheme(.light)
}
