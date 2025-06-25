//
//  MetricsView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct MetricsView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    
    private var averageStreakLength: Int {
        let streaks = viewModel.sobrietyData.pastStreaks
        guard !streaks.isEmpty else { return viewModel.currentStreak }
        let totalDays = streaks.reduce(0) { $0 + $1.length } + viewModel.currentStreak
        return totalDays / (streaks.count + 1)
    }
    
    private var totalSoberDays: Int {
        viewModel.sobrietyData.pastStreaks.reduce(0) { $0 + $1.length } + viewModel.currentStreak
    }
    
    private var successRate: Double {
        let totalDays = Calendar.current.dateComponents([.day], from: viewModel.sobrietyData.pastStreaks.first?.startDate ?? viewModel.sobrietyData.currentStartDate, to: Date()).day ?? 0
        guard totalDays > 0 else { return 100.0 }
        return (Double(totalSoberDays) / Double(totalDays)) * 100
    }
    
    private var shortestStreak: Int {
        let pastStreaks = viewModel.sobrietyData.pastStreaks.map { $0.length }
        if pastStreaks.isEmpty {
            return viewModel.currentStreak
        }
        return min(pastStreaks.min() ?? .max, viewModel.currentStreak)
    }
    
    var body: some View {
        List {
            Section {
                MetricRow(title: "Current Streak", value: "\(viewModel.currentStreak) days", icon: "calendar")
                MetricRow(title: "Longest Streak", value: "\(viewModel.longestStreak) days", icon: "star.fill")
                MetricRow(title: "Total Attempts", value: "\(viewModel.totalAttempts)", icon: "arrow.triangle.2.circlepath")
            } header: {
                Text("Current Status")
            }
            
            Section {
                MetricRow(title: "Total Sober Days", value: "\(totalSoberDays) days", icon: "sum")
                MetricRow(title: "Average Streak", value: "\(averageStreakLength) days", icon: "chart.bar.fill")
                MetricRow(title: "Shortest Streak", value: "\(shortestStreak) days", icon: "chart.bar")
                MetricRow(title: "Success Rate", value: String(format: "%.1f%%", successRate), icon: "percent")
            } header: {
                Text("Statistics")
            }
            
            if !viewModel.sobrietyData.pastStreaks.isEmpty {
                Section {
                    ForEach(viewModel.sobrietyData.pastStreaks.sorted(by: { $0.endDate > $1.endDate })) { streak in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(streak.length) days")
                                .font(.headline)
                            Text("\(streak.startDate.formatted(date: .abbreviated, time: .omitted)) - \(streak.endDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Past Streaks")
                }
            }
        }
        .navigationTitle("Metrics")
    }
}

struct MetricRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        MetricsView()
            .environmentObject(DayCounterViewModel.shared)
    }
} 