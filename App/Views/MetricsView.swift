//
//  MetricsView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct MetricsView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    
    // Metrics are now computed in the ViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Metrics List
                List {
                    Section {
                        MetricRow(title: "Current Streak", value: "\(viewModel.currentStreak) days", icon: "calendar")
                        MetricRow(title: "Longest Streak", value: "\(viewModel.longestStreak) days", icon: "star.fill")
                        MetricRow(title: "Total Attempts", value: "\(viewModel.totalAttempts)", icon: "arrow.triangle.2.circlepath")
                    } header: {
                        Text("Current Status")
                    }
                    
                    Section {
                        MetricRow(title: "Total Sober Days", value: "\(viewModel.totalSoberDays) days", icon: "sum")
                        MetricRow(title: "Average Streak", value: "\(viewModel.averageStreakLength) days", icon: "chart.bar.fill")
                        MetricRow(title: "Success Rate", value: String(format: "%.1f%%", viewModel.successRate), icon: "percent")
                    } header: {
                        Text("Statistics")
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .frame(height: 320)
                
                // Calendar Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calendar")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    CalendarView()
                        .frame(height: 380)
                        .padding(.horizontal)
                }
                .background(Color(.systemGroupedBackground))
                
                // Past Streaks
                if !viewModel.sobrietyData.pastStreaks.isEmpty {
                    List {
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
                    .listStyle(InsetGroupedListStyle())
                    .frame(height: min(CGFloat(viewModel.sobrietyData.pastStreaks.count * 60 + 50), 300))
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Metrics")
        .background(Color(.systemGroupedBackground))
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
            .environmentObject(AppSettingsViewModel.shared)
    }
} 
