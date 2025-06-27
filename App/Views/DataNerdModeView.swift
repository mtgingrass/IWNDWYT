//
//  DataNerdModeView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on [Date]
//

import SwiftUI

struct DataNerdModeView: View {
    @EnvironmentObject private var dayCounterViewModel: DayCounterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                            
                            Text("Data Nerd Mode")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                        
                        Text("Dive deep into your journey with comprehensive analytics")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Quick Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickStatCard(
                            title: "Current Streak",
                            value: "\(dayCounterViewModel.currentStreak)",
                            subtitle: "days",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        QuickStatCard(
                            title: "Longest Streak",
                            value: "\(dayCounterViewModel.longestStreak)",
                            subtitle: "days",
                            icon: "trophy.fill",
                            color: .yellow
                        )
                        
                        QuickStatCard(
                            title: "Total Attempts",
                            value: "\(dayCounterViewModel.totalAttempts)",
                            subtitle: "streaks",
                            icon: "arrow.up.circle.fill",
                            color: .blue
                        )
                        QuickStatCard(
                            title: "Avg Streak",
                            value: "\(dayCounterViewModel.averageStreakLength)",
                            subtitle: "days",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .purple
                        )
                        
                        QuickStatCard(
                            title: "Total Sober Days",
                            value: "\(dayCounterViewModel.totalSoberDays)",
                            subtitle: "days",
                            icon: "calendar.circle.fill",
                            color: .mint
                        )
                    }
                    
                    // Monthly Analysis
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundColor(.accentColor)
                            Text("Monthly Analysis")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            MonthlyComparisonRow(
                                title: "Longest Streak This Month",
                                thisMonth: longestStreakThisMonth,
                                lastMonth: longestStreakLastMonth
                            )
                            
                            MonthlyComparisonRow(
                                title: "Total Days This Month",
                                thisMonth: totalDaysThisMonth,
                                lastMonth: totalDaysLastMonth
                            )
                            
                            MonthlyComparisonRow(
                                title: "Attempts This Month",
                                thisMonth: attemptsThisMonth,
                                lastMonth: attemptsLastMonth
                            )
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 1)
                    }
                    
                    // Yearly Analysis
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.accentColor)
                            Text("Yearly Analysis")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            YearlyComparisonRow(
                                title: "Longest Streak This Year",
                                thisYear: longestStreakThisYear,
                                lastYear: longestStreakLastYear
                            )
                            
                            YearlyComparisonRow(
                                title: "Total Days This Year",
                                thisYear: totalDaysThisYear,
                                lastYear: totalDaysLastYear
                            )
                            
                            YearlyComparisonRow(
                                title: "Attempts This Year",
                                thisYear: attemptsThisYear,
                                lastYear: attemptsLastYear
                            )
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 1)
                    }
                    
                    // Detailed Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                                .foregroundColor(.accentColor)
                            Text("Detailed Breakdown")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        VStack(spacing: 8) {
                            DataBreakdownRow(label: "Total Streaks Recorded", value: "\(totalStreaksRecorded)")
                            DataBreakdownRow(label: "Median Streak Length", value: "\(medianStreakLength) days")
                            DataBreakdownRow(label: "Days Since First Attempt", value: "\(daysSinceFirstAttempt) days")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 1)
                    }
                }
                .padding()
            }
            .navigationTitle("Data Nerd Mode")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct MonthlyComparisonRow: View {
    let title: String
    let thisMonth: Int
    let lastMonth: Int
    
    private var trendIcon: String {
        if lastMonth == 0 && thisMonth == 0 {
            return "minus"
        } else if lastMonth == 0 && thisMonth > 0 {
            return "arrow.up"
        } else if thisMonth > lastMonth {
            return "arrow.up"
        } else if thisMonth < lastMonth {
            return "arrow.down"
        } else {
            return "minus"
        }
    }
    
    private var trendColor: Color {
        if lastMonth == 0 && thisMonth == 0 {
            return .gray
        } else if lastMonth == 0 && thisMonth > 0 {
            return .green
        } else if thisMonth > lastMonth {
            return .green
        } else if thisMonth < lastMonth {
            return .red
        } else {
            return .orange
        }
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            HStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("This")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(thisMonth)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Last")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(lastMonth == 0 ? "-" : "\(lastMonth)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(lastMonth == 0 ? .secondary : .primary)
                }
                
                // Trend indicator
                Image(systemName: trendIcon)
                    .foregroundColor(trendColor)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

struct YearlyComparisonRow: View {
    let title: String
    let thisYear: Int
    let lastYear: Int
    
    private var trendIcon: String {
        if lastYear == 0 && thisYear == 0 {
            return "minus"
        } else if lastYear == 0 && thisYear > 0 {
            return "arrow.up"
        } else if thisYear > lastYear {
            return "arrow.up"
        } else if thisYear < lastYear {
            return "arrow.down"
        } else {
            return "minus"
        }
    }
    
    private var trendColor: Color {
        if lastYear == 0 && thisYear == 0 {
            return .gray
        } else if lastYear == 0 && thisYear > 0 {
            return .green
        } else if thisYear > lastYear {
            return .green
        } else if thisYear < lastYear {
            return .red
        } else {
            return .orange
        }
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            HStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("This")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(thisYear)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Last")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(lastYear == 0 ? "-" : "\(lastYear)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(lastYear == 0 ? .secondary : .primary)
                }
                
                // Trend indicator
                Image(systemName: trendIcon)
                    .foregroundColor(trendColor)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

struct DataBreakdownRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Data Models

// MARK: - Computed Properties Extension

extension DataNerdModeView {
    
    // Monthly Analysis
    private var longestStreakThisMonth: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let thisMonth = calendar.dateInterval(of: .month, for: now)!
        
        let streaksThisMonth = dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            thisMonth.contains(streak.startDate)
        }
        
        var maxStreak = streaksThisMonth.map { $0.length }.max() ?? 0
        
        // Check if current streak started this month
        if dayCounterViewModel.isActiveStreak && thisMonth.contains(dayCounterViewModel.sobrietyData.currentStartDate) {
            maxStreak = max(maxStreak, dayCounterViewModel.currentStreak)
        }
        
        return maxStreak
    }
    
    private var longestStreakLastMonth: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
        let lastMonthInterval = calendar.dateInterval(of: .month, for: lastMonth)!
        
        return dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            lastMonthInterval.contains(streak.startDate)
        }.map { $0.length }.max() ?? 0
    }
    
    private var totalDaysThisMonth: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let thisMonth = calendar.dateInterval(of: .month, for: now)!
        
        let streaksThisMonth = dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            thisMonth.contains(streak.startDate)
        }
        
        var totalDays = streaksThisMonth.reduce(0) { $0 + $1.length }
        
        if dayCounterViewModel.isActiveStreak && thisMonth.contains(dayCounterViewModel.sobrietyData.currentStartDate) {
            totalDays += dayCounterViewModel.currentStreak
        }
        
        return totalDays
    }
    
    private var totalDaysLastMonth: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
        let lastMonthInterval = calendar.dateInterval(of: .month, for: lastMonth)!
        
        return dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            lastMonthInterval.contains(streak.startDate)
        }.reduce(0) { $0 + $1.length }
    }
    
    private var attemptsThisMonth: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let thisMonth = calendar.dateInterval(of: .month, for: now)!
        
        var attempts = dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            thisMonth.contains(streak.startDate)
        }.count
        
        if dayCounterViewModel.isActiveStreak && thisMonth.contains(dayCounterViewModel.sobrietyData.currentStartDate) {
            attempts += 1
        }
        
        return attempts
    }
    
    private var attemptsLastMonth: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
        let lastMonthInterval = calendar.dateInterval(of: .month, for: lastMonth)!
        
        return dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            lastMonthInterval.contains(streak.startDate)
        }.count
    }
    
    // Yearly Analysis
    private var longestStreakThisYear: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let thisYear = calendar.dateInterval(of: .year, for: now)!
        
        let streaksThisYear = dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            thisYear.contains(streak.startDate)
        }
        
        var maxStreak = streaksThisYear.map { $0.length }.max() ?? 0
        
        // Check if current streak started this year
        if dayCounterViewModel.isActiveStreak && thisYear.contains(dayCounterViewModel.sobrietyData.currentStartDate) {
            maxStreak = max(maxStreak, dayCounterViewModel.currentStreak)
        }
        
        return maxStreak
    }
    
    private var longestStreakLastYear: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let lastYear = calendar.date(byAdding: .year, value: -1, to: now)!
        let lastYearInterval = calendar.dateInterval(of: .year, for: lastYear)!
        
        return dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            lastYearInterval.contains(streak.startDate)
        }.map { $0.length }.max() ?? 0
    }
    
    private var totalDaysThisYear: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let thisYear = calendar.dateInterval(of: .year, for: now)!
        
        let streaksThisYear = dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            thisYear.contains(streak.startDate)
        }
        
        var totalDays = streaksThisYear.reduce(0) { $0 + $1.length }
        
        if dayCounterViewModel.isActiveStreak && thisYear.contains(dayCounterViewModel.sobrietyData.currentStartDate) {
            totalDays += dayCounterViewModel.currentStreak
        }
        
        return totalDays
    }
    
    private var totalDaysLastYear: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let lastYear = calendar.date(byAdding: .year, value: -1, to: now)!
        let lastYearInterval = calendar.dateInterval(of: .year, for: lastYear)!
        
        return dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            lastYearInterval.contains(streak.startDate)
        }.reduce(0) { $0 + $1.length }
    }
    
    private var attemptsThisYear: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let thisYear = calendar.dateInterval(of: .year, for: now)!
        
        var attempts = dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            thisYear.contains(streak.startDate)
        }.count
        
        if dayCounterViewModel.isActiveStreak && thisYear.contains(dayCounterViewModel.sobrietyData.currentStartDate) {
            attempts += 1
        }
        
        return attempts
    }
    
    private var attemptsLastYear: Int {
        let calendar = Calendar.current
        let now = DateProvider.now
        let lastYear = calendar.date(byAdding: .year, value: -1, to: now)!
        let lastYearInterval = calendar.dateInterval(of: .year, for: lastYear)!
        
        return dayCounterViewModel.sobrietyData.pastStreaks.filter { streak in
            lastYearInterval.contains(streak.startDate)
        }.count
    }
    
    // Detailed Breakdown
    private var totalStreaksRecorded: Int {
        dayCounterViewModel.sobrietyData.pastStreaks.count + (dayCounterViewModel.isActiveStreak ? 1 : 0)
    }
    

    private var medianStreakLength: Int {
        let pastStreaks = dayCounterViewModel.sobrietyData.pastStreaks.map { $0.length }
        let allStreaks = dayCounterViewModel.isActiveStreak ? pastStreaks + [dayCounterViewModel.currentStreak] : pastStreaks
        let sortedStreaks = allStreaks.sorted()
        
        guard !sortedStreaks.isEmpty else { return 0 }
        
        if sortedStreaks.count % 2 == 0 {
            return (sortedStreaks[sortedStreaks.count / 2 - 1] + sortedStreaks[sortedStreaks.count / 2]) / 2
        } else {
            return sortedStreaks[sortedStreaks.count / 2]
        }
    }
    
    private var daysSinceFirstAttempt: Int {
        guard let firstStreak = dayCounterViewModel.sobrietyData.pastStreaks.min(by: { $0.startDate < $1.startDate }) else {
            return dayCounterViewModel.currentStreak
        }
        
        let startDate = dayCounterViewModel.isActiveStreak ? 
            min(firstStreak.startDate, dayCounterViewModel.sobrietyData.currentStartDate) : 
            firstStreak.startDate
        
        return Calendar.current.dateComponents([.day], from: startDate, to: DateProvider.now).day ?? 0
    }
    

}

#Preview {
    DataNerdModeView()
        .environmentObject(DayCounterViewModel.shared)
}
