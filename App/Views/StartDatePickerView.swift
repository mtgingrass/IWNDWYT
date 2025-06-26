//
//  StartDatePickerView.swift
//  IWNDWYToday
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct StartDatePickerView: View {
    @EnvironmentObject private var settings: AppSettingsViewModel
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @State private var selectedDate = Date()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Choose Your Start Date")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("When did you start your journey? This will be used to calculate your progress.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Date Picker
                VStack(spacing: 16) {
                    Text("Select Start Date")
                        .font(.headline)
                    
                    DatePicker(
                        "Start Date",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Important Note
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("Important")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    
                    Text("This can only be set once, or when you reset all data. Choose carefully!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: confirmDate) {
                        Text("Confirm & Start Tracking")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                    
                    Button(action: skipDateSelection) {
                        Text("Skip - Use Today's Date")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        skipDateSelection()
                    }
                }
            }
        }
    }
    
    private func confirmDate() {
        // Save the custom start date
        settings.customStartDate = selectedDate
        settings.hasChosenStartDate = true
        
        // Start the streak with the selected date
        viewModel.startStreakWithCustomDate(selectedDate)
        
        dismiss()
    }
    
    private func skipDateSelection() {
        // Use today's date
        settings.customStartDate = Date()
        settings.hasChosenStartDate = true
        
        // Start the streak with today's date
        viewModel.startStreakWithCustomDate(Date())
        
        dismiss()
    }
}

#Preview {
    StartDatePickerView()
        .environmentObject(AppSettingsViewModel.shared)
        .environmentObject(DayCounterViewModel.shared)
} 