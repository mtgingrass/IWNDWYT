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
        let hours = Int(timeUntilMidnight) / 3600
        let minutes = Int(timeUntilMidnight) / 60 % 60
        let seconds = Int(timeUntilMidnight) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private var streakCountdownBox: some View {
        NavigationLink(destination: MetricsView(showingSettings: $showingSettings)) {
            VStack(spacing: 12) {
                Text("🟢 \(viewModel.currentStreak) days")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                    .padding(.top, 8)

                HStack(spacing: 4) {
                    Text("Countdown:")
                        .foregroundColor(.primary)
                    Text("\(formatTimeRemaining())")
                        .font(.system(.title3, design: .monospaced))
                        .foregroundColor(.orange)
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
                    Text("Milestones")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    MilestoneProgressView(currentStreak: viewModel.currentStreak)
                        .padding(.vertical, 12)
                        .frame(maxHeight: 320)
                }

                // End/Cancel Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showEndConfirmation = true
                    }) {
                        Text("End Streak")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }

                    if Calendar.current.isDate(viewModel.sobrietyData.currentStartDate, inSameDayAs: DateProvider.now) {
                        Button(action: {
                            showCancelConfirmation = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.uturn.backward")
                                Text("Cancel Streak")
                            }
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.red.opacity(0.3), lineWidth: 1))
                        }
                    }
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
            updateTimeUntilMidnight()
        }
        .onReceive(timer) { _ in
            updateTimeUntilMidnight()
        }
        .navigationTitle("Streak Progress")
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
        .alert("End Current Streak?", isPresented: $showEndConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("End Streak", role: .destructive) {
                viewModel.endStreak()
                selectedTab = 0
            }
        } message: {
            Text("Are you sure you want to end your current streak? This will mark today as the end date.")
        }
        .alert("Cancel Streak?", isPresented: $showCancelConfirmation) {
            Button("Keep Streak", role: .cancel) { }
            Button("Cancel Streak", role: .destructive) {
                viewModel.cancelStreak()
                selectedTab = 0
            }
        } message: {
            Text("This will completely remove this streak attempt. It won't be saved or counted in your history. This action cannot be undone.")
        }
    }
}

#Preview {
    ActiveStreakView(selectedTab: .constant(0), showingSettings: .constant(false))
        .environmentObject(DayCounterViewModel.shared)
}
