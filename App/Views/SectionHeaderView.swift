//
//  SectionHeaderView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let systemImage: String?

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(.accentColor)
            }

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
        .padding(.horizontal)
        .transition(.opacity)
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeaderView(title: "YOUR DASHBOARD", systemImage: "chart.bar.fill")
        SectionHeaderView(title: "DETAILED HISTORY", systemImage: "clock.fill")
        SectionHeaderView(title: "NO ICON", systemImage: nil)
    }
    .padding()
} 
