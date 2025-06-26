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
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 10)

                    // Header Button
                    Button(action: {
                        if viewModel.isActiveStreak {
                            navigateToStreakView = true
                        } else {
                            withAnimation {
                                viewModel.startStreak()
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: viewModel.isActiveStreak ? "flame.fill" : "sunrise.fill")
                                .imageScale(.large)
                            Text(viewModel.isActiveStreak ? "Streak in Progress" : "Start New Streak")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isActiveStreak ? Color.orange : Color.green)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    NavigationLink(destination: ActiveStreakView(), isActive: $navigateToStreakView) {
                        EmptyView()
                    }

                    SectionHeaderView(title: "YOUR PROGRESS", systemImage: "chart.bar.fill")

                    VStack(spacing: 12) {
                        MetricCardView(icon: "🏆", title: "Best Streak", value: "\(viewModel.longestStreak) days", valueColor: .green)

                        if let lastStreak = viewModel.sobrietyData.pastStreaks.sorted(by: { $0.endDate > $1.endDate }).first {
                            MetricCardView(icon: "⏱", title: "Previous Streak Ended", value: "\(lastStreak.length) days ago", valueColor: .primary)
                        }

                        MetricCardView(icon: "📈", title: "Total Attempts", value: "\(viewModel.totalAttempts)", valueColor: .primary)
                    }
                    .padding(.horizontal)

                    SectionHeaderView(title: "DETAILED HISTORY", systemImage: "chart.bar.fill")

                    NavigationLink(destination: MetricsView()) {
                        MetricCardView(
                            icon: "📊",
                            title: "Progress & History",
                            value: "View Details",
                            valueColor: .secondary
                        )
                    }
                    .padding(.horizontal)

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
            .navigationBarTitle("IWNDWYT", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        settings.toggleColorScheme()
                    } label: {
                        Image(systemName: settings.colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                            .imageScale(.medium)
                            .foregroundColor(settings.colorScheme == .dark ? .yellow : .primary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}



struct SectionHeaderView: View {
    let title: String
    let systemImage: String?

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(.accentColor)
            }

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
        .padding(.horizontal)
        .transition(.opacity)
    }
}

#Preview {
    ContentView()
        .environmentObject(DayCounterViewModel.shared)
        .environmentObject(AppSettingsViewModel.shared)
}
