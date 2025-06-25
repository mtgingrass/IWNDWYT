//
//  CalendarView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @State private var selectedMonth = Date()
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Start week on Sunday
        return calendar
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(selectedMonth.formatted(.dateTime.month().year()))
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Day of week row
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            
            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(date: date,
                               isSelected: calendar.isDate(date, inSameDayAs: selectedMonth),
                               status: getDayStatus(date))
                            .onTapGesture {
                                selectedMonth = date
                            }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
        }
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: selectedMonth)!
        let firstDay = interval.start
        
        // Calculate the first date to show (including leading dates from previous month)
        let weekdayOfFirst = calendar.component(.weekday, from: firstDay)
        let leadingDates = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        
        let firstDateToShow = calendar.date(byAdding: .day, value: -leadingDates, to: firstDay)!
        
        var dates: [Date?] = []
        var currentDate = firstDateToShow
        
        // We'll always show 42 spots (6 weeks)
        for _ in 0..<42 {
            if calendar.isDate(currentDate, equalTo: interval.start, toGranularity: .month) ||
               calendar.isDate(currentDate, equalTo: interval.end, toGranularity: .month) {
                dates.append(currentDate)
            } else {
                dates.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private func getDayStatus(_ date: Date) -> DayStatus {
        guard date <= DateProvider.now else { return .future }
        
        // Check if it's within any streak
        for streak in viewModel.sobrietyData.pastStreaks {
            if date >= streak.startDate && date <= streak.endDate {
                return .sober
            }
        }
        
        // Check current streak
        if viewModel.sobrietyData.isActiveStreak &&
           date >= viewModel.sobrietyData.currentStartDate &&
           date <= DateProvider.now {
            return .sober
        }
        
        // If the date is before the first streak or between streaks
        let firstTrackingDate = viewModel.sobrietyData.pastStreaks.first?.startDate ?? viewModel.sobrietyData.currentStartDate
        if date >= firstTrackingDate {
            return .nonSober
        }
        
        return .beforeTracking
    }
}

enum DayStatus {
    case sober
    case nonSober
    case beforeTracking
    case future
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let status: DayStatus
    
    private var backgroundColor: Color {
        switch status {
        case .sober:
            return .green.opacity(0.3)
        case .nonSober:
            return .red.opacity(0.3)
        case .beforeTracking, .future:
            return .clear
        }
    }
    
    private var textColor: Color {
        switch status {
        case .sober:
            return .primary
        case .nonSober:
            return .primary
        case .beforeTracking, .future:
            return .secondary
        }
    }
    
    var body: some View {
        Text(date.formatted(.dateTime.day()))
            .font(.callout)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
    }
}

#Preview {
    CalendarView()
        .environmentObject(DayCounterViewModel.shared)
        .padding()
} 