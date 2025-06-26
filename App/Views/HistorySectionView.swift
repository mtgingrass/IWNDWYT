//
//  HistorySectionView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct HistorySectionView: View {
    var body: some View {
        VStack(spacing: 12) {
            SectionHeaderView(title: "DETAILED HISTORY", systemImage: "chart.bar.fill")
            
            MetricCardView(
                icon: "📊",
                title: "Progress & History",
                value: "Check Metrics Tab",
                valueColor: .secondary
            )
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationView {
        HistorySectionView()
            .padding()
    }
} 