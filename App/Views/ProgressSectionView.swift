//
//  ProgressSectionView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct ProgressSectionView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            SectionHeaderView(title: "YOUR PROGRESS", systemImage: "chart.bar.fill")
            
            VStack(spacing: 12) {
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
    }
}

#Preview {
    ProgressSectionView()
        .environmentObject(DayCounterViewModel.shared)
        .padding()
} 
