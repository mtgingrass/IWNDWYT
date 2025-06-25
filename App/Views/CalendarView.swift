//
//  CalendarView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @State private var forceUpdate = false // Used to force view updates
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let daysToShow = 365 // Show last year
    
    private var soberDays: Set<Date> {
        var days = Set<Date>()
        
        // Add days from past streaks
        for streak in viewModel.sobrietyData.pastStreaks {
            var currentDate = streak.startDate
            while currentDate <= streak.endDate {
                days.insert(Calendar.current.startOfDay(for: currentDate))
                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }
        
        // Add days from current streak
        var currentDate = viewModel.sobrietyData.currentStartDate
        let now = DateProvider.now
        while currentDate <= now {
            days.insert(Calendar.current.startOfDay(for: currentDate))
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    private var dateRange: [Date] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: DateProvider.now)
        let startDate = calendar.date(byAdding: .day, value: -daysToShow + 1, to: endDate) ?? endDate
        
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Pad with empty cells at the start to align with weekday
        let firstWeekday = calendar.component(.weekday, from: startDate)
        let padding = (firstWeekday + 5) % 7 // Convert to Monday-based week
        if padding > 0 {
            for _ in 0..<padding {
                dates.insert(Date.distantPast, at: 0)
            }
        }
        
        return dates
    }
    
    private func cellColor(for date: Date) -> Color {
        guard date != Date.distantPast else { return .clear }
        
        if soberDays.contains(Calendar.current.startOfDay(for: date)) {
            return .green.opacity(0.8)
        }
        return Color(.systemGray6)
    }
    
    private func formattedDate(_ date: Date) -> String {
        guard date != Date.distantPast else { return "" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(dateRange, id: \.timeIntervalSince1970) { date in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(for: date))
                        .frame(height: 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                        .help(formattedDate(date))
                }
            }
            
            HStack {
                Text("Less")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.systemGray6))
                    .frame(width: 20, height: 20)
                RoundedRectangle(cornerRadius: 2)
                    .fill(.green.opacity(0.8))
                    .frame(width: 20, height: 20)
                Text("More")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .id(forceUpdate) // Force view update when date changes
        .onAppear {
            #if DEBUG
            NotificationCenter.default.addObserver(
                forName: .dateOffsetChanged,
                object: nil,
                queue: .main
            ) { _ in
                // Toggle state to force view update
                forceUpdate.toggle()
            }
            #endif
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(DayCounterViewModel.shared)
        .padding()
} 