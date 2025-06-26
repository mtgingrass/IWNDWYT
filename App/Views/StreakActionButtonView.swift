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
                }
            }
        }) {
            HStack {
                Image(systemName: viewModel.isActiveStreak ? "flame.fill" : "sunrise.fill")
                    .imageScale(.large)
                Text(viewModel.isActiveStreak ? "View Active Streak" : "Start New Streak")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(viewModel.isActiveStreak ? Color.orange : Color.green)
            .cornerRadius(10)
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
