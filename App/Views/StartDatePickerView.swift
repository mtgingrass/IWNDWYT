//
//  StartDatePickerView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on [Date]
//

import SwiftUI

struct StartDatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dayCounterViewModel: DayCounterViewModel
    @EnvironmentObject private var appSettings: AppSettingsViewModel
    
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Choose Your Start Date")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("When did you start your journey? Select a date to track your progress from that point.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Date Picker
                VStack(spacing: 12) {
                    Text("Start Date")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    DatePicker(
                        "Start Date",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .frame(height: 200)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: confirmStartDate) {
                        Text("Confirm & Start Tracking")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    
                    Button(action: skipDateSelection) {
                        Text("Not Today - I will start another time")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // Default to today
            selectedDate = Date()
        }
    }
    
    private func confirmStartDate() {
        dayCounterViewModel.startStreakWithCustomDate(selectedDate)
        appSettings.markStartDateChosen()
        dismiss()
    }
    
    private func skipDateSelection() {
        // Don't start a streak - just mark that they've seen the picker
        appSettings.markStartDateChosen()
        dismiss()
    }
}

#Preview {
    StartDatePickerView()
        .environmentObject(DayCounterViewModel.shared)
        .environmentObject(AppSettingsViewModel.shared)
} 