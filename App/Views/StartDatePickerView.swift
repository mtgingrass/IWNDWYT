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
                    
                    Text(NSLocalizedString("start_date_title", comment: "Choose your start date title"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(NSLocalizedString("start_date_description", comment: "Start date description"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Date Picker
                VStack(spacing: 12) {
                    Text(NSLocalizedString("form_start_date", comment: "Start date label"))
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    DatePicker(
                        NSLocalizedString("form_start_date", comment: "Start date label"),
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
                        Text(NSLocalizedString("start_date_confirm", comment: "Confirm and start tracking button"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    
                    Button(action: skipDateSelection) {
                        Text(NSLocalizedString("start_date_not_today", comment: "Not today button"))
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