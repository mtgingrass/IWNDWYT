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
        .alert("Same-Day Restart", isPresented: $viewModel.showingSameDayRestartAlert) {
            Button("Start Tomorrow", role: .cancel) {
                viewModel.startStreakTomorrow()
            }
            Button("Override (Start Today)") {
                viewModel.overrideAndStartToday()
            }
            Button("Cancel") {
                viewModel.cancelSameDayRestart()
            }
        } message: {
            Text("You ended a streak today. Would you like to start fresh tomorrow (recommended) or override and make today a successful day?")
        }
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
