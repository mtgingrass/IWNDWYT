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
                MetricCardView(icon: "🏆", title: "Best Streak", value: "\(viewModel.longestStreak) days", valueColor: .green)

                if let lastStreak = viewModel.sobrietyData.pastStreaks.sorted(by: { $0.endDate > $1.endDate }).first {
                    MetricCardView(icon: "⏱", title: "Previous Streak Ended", value: "\(lastStreak.length) days ago", valueColor: .primary)
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