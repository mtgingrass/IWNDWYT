//
//  HistorySectionView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct HistorySectionView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 12) {
            SectionHeaderView(title: "DETAILED HISTORY", systemImage: "chart.bar.fill")
            
            Button(action: {
                // Switch to metrics tab
                selectedTab = viewModel.isActiveStreak ? 2 : 1
            }) {
                MetricCardView(
                    icon: "📊",
                    title: "Progress & History",
                    value: "View Details",
                    valueColor: .secondary
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
        }
    }
}

#Preview {
    HistorySectionView(selectedTab: .constant(0))
        .environmentObject(DayCounterViewModel.shared)
        .padding()
} 