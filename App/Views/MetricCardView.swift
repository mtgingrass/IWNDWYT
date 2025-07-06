//
//  MetricCardView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/26/25.
//

import SwiftUI

struct MetricCardView: View {
    let icon: String
    let title: String
    let value: String
    let valueColor: Color

    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .foregroundColor(valueColor)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 16) {
        MetricCardView(icon: "🔥", title: "Current Streak", value: "7 days", valueColor: .primary)
        MetricCardView(icon: "⭐️", title: "Longest Streak", value: "30 days", valueColor: .green)
        MetricCardView(icon: "📊", title: "Success Rate", value: "85.2%", valueColor: .blue)
    }
    .padding()
}
