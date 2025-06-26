//
//  StreakActionButtonView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct StreakActionButtonView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @Binding var navigateToStreakView: Bool
    
    var body: some View {
        Button(action: {
            if !viewModel.isActiveStreak {
                withAnimation {
                    viewModel.startStreak()
                }
            }
        }) {
            HStack {
                Image(systemName: viewModel.isActiveStreak ? "flame.fill" : "sunrise.fill")
                    .imageScale(.large)
                Text(viewModel.isActiveStreak ? "Streak in Progress - Check Streak Tab" : "Start New Streak")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(viewModel.isActiveStreak ? Color.orange : Color.green)
            .cornerRadius(10)
        }
        .disabled(viewModel.isActiveStreak)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

#Preview {
    @Previewable @State var navigateToStreakView = false
    
    VStack(spacing: 20) {
        StreakActionButtonView(navigateToStreakView: $navigateToStreakView)
            .environmentObject(DayCounterViewModel.shared)
    }
    .padding()
} 