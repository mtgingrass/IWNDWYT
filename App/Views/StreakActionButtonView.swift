//
//  StreakActionButtonView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct StreakActionButtonView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            if viewModel.isActiveStreak {
                // Switch to streak tab (tab 1)
                selectedTab = 1
            } else {
                withAnimation {
                    viewModel.startStreak()
                    // Switch to the streak tab after starting
                    selectedTab = 1
                }
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isActiveStreak ? "flame.fill" : "sunrise.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                Text(viewModel.isActiveStreak ? "View Active Streak" : "Start New Streak")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: viewModel.isActiveStreak ? 
                        [Color.green.opacity(0.8), Color.green] : 
                        [Color.red.opacity(0.8), Color.red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: viewModel.isActiveStreak ? 
                    Color.green.opacity(0.4) : 
                    Color.red.opacity(0.4),
                radius: 10,
                x: 0,
                y: 5
            )
        }
        .disabled(false)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

#Preview {
    @Previewable @State var selectedTab = 0
    
    VStack(spacing: 20) {
        StreakActionButtonView(selectedTab: $selectedTab)
            .environmentObject(DayCounterViewModel.shared)
    }
    .padding()
} 
