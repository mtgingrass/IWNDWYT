//
//  MetricsView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct MetricsView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @Binding var showingSettings: Bool
    
    // Metrics are now computed in the ViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Metrics List
                List {
                    Section {
                        MetricRowView(title: NSLocalizedString("metric_current_streak", comment: "Current streak title"), value: "Day \(viewModel.currentStreak)", icon: "calendar")
                        MetricRowView(title: NSLocalizedString("metric_longest_streak", comment: "Longest streak title"), value: "\(viewModel.longestStreak) \(NSLocalizedString("unit_days", comment: "Days unit"))", icon: "star.fill")
                        MetricRowView(title: NSLocalizedString("metric_total_attempts", comment: "Total attempts title"), value: "\(viewModel.totalAttempts)", icon: "arrow.triangle.2.circlepath")
                    } header: {
                        Text(NSLocalizedString("header_current_status", comment: "Current status header"))
                    }
                    
                    Section {
                        MetricRowView(title: NSLocalizedString("metric_total_success_days", comment: "Total success days title"), value: "\(viewModel.totalSoberDays) \(NSLocalizedString("unit_days", comment: "Days unit"))", icon: "sum")
                        MetricRowView(title: NSLocalizedString("metric_average_streak", comment: "Average streak title"), value: "\(viewModel.averageStreakLength) \(NSLocalizedString("unit_days", comment: "Days unit"))", icon: "chart.bar.fill")
                        MetricRowView(title: NSLocalizedString("metric_success_rate", comment: "Success rate title"), value: String(format: "%.1f%%", viewModel.successRate), icon: "percent")
                    } header: {
                        Text(NSLocalizedString("header_statistics", comment: "Statistics header"))
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
                            Text(NSLocalizedString("metric_data_nerd_mode", comment: "Data nerd mode title"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(NSLocalizedString("metric_data_nerd_desc", comment: "Data nerd mode description"))
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
                VStack(alignment: .leading, spacing: 12) {
                    Text(NSLocalizedString("header_calendar", comment: "Calendar header"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                    
                    CalendarView()
                        .frame(height: 210)
                        .padding(.horizontal)
                }
                .background(Color(.systemGroupedBackground))
                
                // Past Streaks
                if !viewModel.streakData.pastStreaks.isEmpty {
                    List {
                        Section {
                            ForEach(viewModel.streakData.pastStreaks.sorted(by: { $0.endDate > $1.endDate })) { streak in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(streak.length) \(NSLocalizedString("unit_days", comment: "Days unit"))")
                                        .font(.headline)
                                    Text("\(streak.startDate.formatted(date: .abbreviated, time: .omitted)) - \(streak.endDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } header: {
                            Text(NSLocalizedString("header_past_streaks", comment: "Past streaks header"))
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .frame(height: min(CGFloat(viewModel.streakData.pastStreaks.count * 60 + 50), 300))
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(NSLocalizedString("nav_metrics", comment: "Metrics navigation title"))
        .background(Color(.systemGroupedBackground))
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
    }
}



#Preview {
    NavigationView {
        MetricsView(showingSettings: .constant(false))
            .environmentObject(DayCounterViewModel.shared)
            .environmentObject(AppSettingsViewModel.shared)
    }
} 
