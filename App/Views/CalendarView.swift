//
//  CalendarView.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @State private var selectedDate = Date()
    @State private var displayedMonth = Date()
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Start week on Sunday
        return calendar
    }
    
    init() {
        // Initialize displayedMonth to start of current month
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        self._displayedMonth = State(initialValue: calendar.date(from: components) ?? Date())
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Explanatory note
            Text(NSLocalizedString("calendar_explanation", comment: "Calendar explanation text"))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
            
            // Month navigation
            HStack {
                Button {
                    withAnimation {
                        previousMonth()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text(displayedMonth.formatted(.dateTime.month().year()))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 120)
                
                Spacer()
                
                Button {
                    withAnimation {
                        nextMonth()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
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
                               isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                               status: getDayStatus(date),
                               isInDisplayedMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month),
                               isToday: calendar.isDate(date, inSameDayAs: DateProvider.now))
                            .onTapGesture {
                                selectedDate = date
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
        if let newDate = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = newDate
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: displayedMonth)!
        let firstDay = interval.start
        
        // Calculate the first date to show (including leading dates from previous month)
        let weekdayOfFirst = calendar.component(.weekday, from: firstDay)
        let leadingDates = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        
        let firstDateToShow = calendar.date(byAdding: .day, value: -leadingDates, to: firstDay)!
        
        var dates: [Date?] = []
        var currentDate = firstDateToShow
        
        // We'll always show 42 spots (6 weeks)
        for _ in 0..<42 {
            if calendar.isDate(currentDate, equalTo: firstDateToShow, toGranularity: .month) ||
               calendar.isDate(currentDate, equalTo: interval.start, toGranularity: .month) ||
               calendar.isDate(currentDate, equalTo: interval.end, toGranularity: .month) {
                dates.append(currentDate)
            } else {
                dates.append(currentDate)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private func getDayStatus(_ date: Date) -> DayStatus {
        guard date <= DateProvider.now else { return .future }
        
        let isToday = Calendar.current.isDate(date, inSameDayAs: DateProvider.now)
        
        // Rule 1: Past streaks = green (successful days)
        for streak in viewModel.streakData.pastStreaks {
            if date >= streak.startDate && date <= streak.endDate {
                return .sober
            }
        }
        
        // Rule 2: Active streak days (excluding today) = green  
        if viewModel.streakData.isActiveStreak &&
           date >= viewModel.streakData.currentStartDate &&
           !isToday { // Explicitly exclude today regardless of date comparison
            return .sober
        }
        
        // Rule 3: Today = always neutral (blank slate)
        if isToday {
            return .beforeTracking
        }
        
        // Rule 4: Any other tracked day = red (relapse days)
        let hasAnyData = !viewModel.streakData.pastStreaks.isEmpty || viewModel.streakData.isActiveStreak
        if hasAnyData {
            let firstTrackingDate = viewModel.streakData.pastStreaks.first?.startDate ?? viewModel.streakData.currentStartDate
            if date >= firstTrackingDate {
                return .nonSober
            }
        }
        
        // Rule 5: Before tracking = clear
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
    let isInDisplayedMonth: Bool
    let isToday: Bool
    
    private var backgroundColor: Color {
        switch status {
        case .sober:
            return .green.opacity(isInDisplayedMonth ? 0.3 : 0.15)
        case .nonSober:
            return .red.opacity(isInDisplayedMonth ? 0.3 : 0.15)
        case .beforeTracking, .future:
            return .clear
        }
    }
    
    private var textColor: Color {
        if !isInDisplayedMonth {
            return .secondary.opacity(0.5)
        }
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
        ZStack {
            Text(date.formatted(.dateTime.day()))
                .font(.callout)
                .fontWeight(isToday ? .bold : .regular)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                )
            
            // Today indicator
            if isToday {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)
                            .padding(.trailing, 4)
                            .padding(.bottom, 4)
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(DayCounterViewModel.shared)
        .padding()
} 
