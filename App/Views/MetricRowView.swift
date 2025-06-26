//
//  MetricRowView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct MetricRowView: View {
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
    List {
        MetricRowView(title: "Current Streak", value: "5 days", icon: "calendar")
        MetricRowView(title: "Longest Streak", value: "23 days", icon: "star.fill")
        MetricRowView(title: "Total Attempts", value: "7", icon: "arrow.triangle.2.circlepath")
    }
} 