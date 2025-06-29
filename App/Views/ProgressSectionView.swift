//
//  ProgressSectionView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct ProgressSectionView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @State private var timeUntilMidnight: TimeInterval = 0
    
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
        VStack(spacing: 12) {
            SectionHeaderView(title: "YOUR DASHBOARD", systemImage: "chart.bar.fill")
            
            VStack(spacing: 12) {
                // Current Active Streak Status
                if viewModel.isActiveStreak {
                    let dateFormatter: DateFormatter = {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        return formatter
                    }()
                    let startDateText = dateFormatter.string(from: viewModel.sobrietyData.currentStartDate)
                    MetricCardView(icon: "🔥", title: "Active Streak Started \(startDateText)", value: "\(viewModel.currentStreak) days", valueColor: .green)
                } else {
                    MetricCardView(icon: "⭕", title: "No Active Streak", value: "Ready to start", valueColor: .secondary)
                }
                
                // Countdown Card
                if viewModel.isActiveStreak {
                    VStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Text("\(formatTimeRemaining())")
                                .font(.system(.title3, design: .monospaced))
                                .foregroundColor(.red)
                            Text(" to next goal")
                                .font(.system(.title3, design: .monospaced))
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                MetricCardView(icon: "🏆", title: "Longest Streak", value: "\(viewModel.longestStreak) days", valueColor: .green)

                if let lastStreak = viewModel.sobrietyData.pastStreaks.sorted(by: { $0.endDate > $1.endDate }).first {
                    let daysSinceEnded = Calendar.current.dateComponents([.day], from: lastStreak.endDate, to: Date()).day ?? 0
                    let daysText = daysSinceEnded == 0 ? "today" : daysSinceEnded == 1 ? "1 day ago" : "\(daysSinceEnded) days ago"
                    MetricCardView(icon: "⏱", title: "Previous Streak Ended", value: daysText, valueColor: .primary)
                }

                MetricCardView(icon: "📈", title: "Total Attempts", value: "\(viewModel.totalAttempts)", valueColor: .primary)
            }
            .padding(.horizontal)
        }
        .onAppear {
            updateTimeUntilMidnight()
        }
        .onReceive(timer) { _ in
            updateTimeUntilMidnight()
        }
    }
}

#Preview {
    ProgressSectionView()
        .environmentObject(DayCounterViewModel.shared)
        .padding()
} 
