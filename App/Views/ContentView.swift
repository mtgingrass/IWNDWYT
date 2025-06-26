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
    @Binding var selectedTab: Int
    @State private var showEndConfirmation = false
    @State private var showCancelConfirmation = false
    @State private var animateProgressSection = false
    @State private var animateHistorySection = false
    @State private var timeUntilMidnight: TimeInterval = 0
    @State private var navigateToStreakView = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private func updateTimeUntilMidnight() {
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.startOfDay(for: now.addingTimeInterval(24*60*60))
        timeUntilMidnight = tomorrow.timeIntervalSince(now)
    }
    
    private func formatTimeRemaining() -> String {
        let hours = Int(timeUntilMidnight) / 3600
        let minutes = Int(timeUntilMidnight) / 60 % 60
        let seconds = Int(timeUntilMidnight) % 60
        
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 10)

                    // Header Button
                    StreakActionButtonView(selectedTab: $selectedTab)

                    ProgressSectionView()

                    HistorySectionView(selectedTab: $selectedTab)

                    #if DEBUG
                    NavigationLink("Open Debug Panel") {
                        DebugPanelView()
                    }
                    .font(.footnote)
                    .padding(.top)
                    #endif
                }
                .padding()
            }
            .onAppear {
                withAnimation(.easeIn(duration: 0.4)) {
                    animateProgressSection = true
                    animateHistorySection = true
                }
                updateTimeUntilMidnight()
            }
            .onReceive(timer) { _ in
                updateTimeUntilMidnight()
            }

    }
}





#Preview {
    ContentView(selectedTab: .constant(0))
        .environmentObject(DayCounterViewModel.shared)
        .environmentObject(AppSettingsViewModel.shared)
}
