//
//  TabBarButton.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .orange : .gray)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .orange : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        TabBarButton(icon: "house.fill", title: "Home", isSelected: true) { }
        TabBarButton(icon: "flame.fill", title: "Streak", isSelected: false) { }
        TabBarButton(icon: "chart.bar.fill", title: "Metrics", isSelected: false) { }
    }
    .padding()
    .background(Color(.systemBackground))
} 