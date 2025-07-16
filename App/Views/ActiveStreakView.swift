//
//  ActiveStreakView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/26/25.
//

//
//  ActiveStreakView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/26/25.
//

import SwiftUI

struct ActiveStreakView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @Binding var selectedTab: Int
    @Binding var showingSettings: Bool
    @State private var showEndConfirmation = false
    @State private var showCancelConfirmation = false
    @State private var timeUntilMidnight: TimeInterval = 0
    @State private var navigateToMetrics = false
    
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
    
    private var streakCountdownBox: some View {
        NavigationLink(destination: MetricsView(showingSettings: $showingSettings)) {
            VStack(spacing: 12) {
                Text("Day \(viewModel.currentStreak)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                HStack(spacing: 4) {
                    Text(NSLocalizedString("active_streak_next_day", comment: "Next day starts in"))
                        .foregroundColor(.primary)
                        //.font(.footnote)
                    
                    Text("\(formatTimeRemaining())")
                        .font(.system(.title3, design: .monospaced))
                        .foregroundColor(.red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(streakBoxBackground)
            .padding(.horizontal)
        }
    }
    
    private var streakBoxBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray6))
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    // Current Streak and Countdown Box  
                    streakCountdownBox


                }
                
                // Milestones
                VStack(spacing: 16) {
                    Text("Completed Milestones")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    MilestoneProgressView(currentStreak: viewModel.currentStreak)
                        .padding(.vertical, 12)
                        .frame(maxHeight: 320)
                }

                // End/Cancel Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        showEndConfirmation = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.circle.fill")
                                .font(.title3)
                            Text(NSLocalizedString("active_streak_end_streak", comment: "End streak button"))
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color.red.opacity(0.8), Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                    }

                    if Calendar.current.isDate(viewModel.streakData.currentStartDate, inSameDayAs: DateProvider.now) {
                        Button(action: {
                            showCancelConfirmation = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.uturn.backward.circle")
                                    .font(.title3)
                                Text(NSLocalizedString("active_streak_cancel_streak", comment: "Cancel streak button"))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.red)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.red.opacity(0.4), lineWidth: 1.5)
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal)

            }
            .padding()
        }
        .onAppear {
            updateTimeUntilMidnight()
        }
        .onReceive(timer) { _ in
            updateTimeUntilMidnight()
        }
        .navigationTitle(NSLocalizedString("nav_streak_progress", comment: "Streak progress navigation title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gear")
                        .imageScale(.medium)
                        .settingsButtonStyle()
                }
            }
        }
        .alert(NSLocalizedString("active_streak_end_confirm_title", comment: "End streak confirmation title"), isPresented: $showEndConfirmation) {
            Button(NSLocalizedString("btn_cancel", comment: "Cancel button"), role: .cancel) { }
            Button(NSLocalizedString("active_streak_end_streak", comment: "End streak button"), role: .destructive) {
                viewModel.endStreak()
                selectedTab = 0
            }
        } message: {
            Text(NSLocalizedString("active_streak_end_confirm_message", comment: "End streak confirmation message"))
        }
        .alert(NSLocalizedString("active_streak_cancel_confirm_title", comment: "Cancel streak confirmation title"), isPresented: $showCancelConfirmation) {
            Button(NSLocalizedString("action_keep_streak", comment: "Keep streak button"), role: .cancel) { }
            Button(NSLocalizedString("active_streak_cancel_streak", comment: "Cancel streak button"), role: .destructive) {
                viewModel.cancelStreak()
                selectedTab = 0
            }
        } message: {
            Text(NSLocalizedString("active_streak_cancel_confirm_message", comment: "Cancel streak confirmation message"))
        }
    }
}

#Preview {
    ActiveStreakView(selectedTab: .constant(0), showingSettings: .constant(false))
        .environmentObject(DayCounterViewModel.shared)
}
