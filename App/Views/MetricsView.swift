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
                        MetricRowView(title: "Current Streak", value: "\(viewModel.currentStreak) days", icon: "calendar")
                        MetricRowView(title: "Longest Streak", value: "\(viewModel.longestStreak) days", icon: "star.fill")
                        MetricRowView(title: "Total Attempts", value: "\(viewModel.totalAttempts)", icon: "arrow.triangle.2.circlepath")
                    } header: {
                        Text("Current Status")
                    }
                    
                    Section {
                        MetricRowView(title: "Total Sober Days", value: "\(viewModel.totalSoberDays) days", icon: "sum")
                        MetricRowView(title: "Average Streak", value: "\(viewModel.averageStreakLength) days", icon: "chart.bar.fill")
                        MetricRowView(title: "Success Rate", value: String(format: "%.1f%%", viewModel.successRate), icon: "percent")
                    } header: {
                        Text("Statistics")
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .frame(height: 320)
                
                // Data Nerd Mode Button
                NavigationLink(destination: DataNerdModeView().environmentObject(viewModel)) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.accentColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Data Nerd Mode")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Dive deep into your analytics")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 1)
                }
                .padding(.horizontal)
                
                // Calendar Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calendar")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    CalendarView()
                        .frame(height: 210)
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



#Preview {
    NavigationView {
        MetricsView()
            .environmentObject(DayCounterViewModel.shared)
            .environmentObject(AppSettingsViewModel.shared)
    }
} 
