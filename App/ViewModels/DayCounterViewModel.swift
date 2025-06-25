//
//  DayCounterViewModel.swift
//  IWNDWYT
//
//  Created by Mark Gingrass on 6/25/25.
//

import Foundation
import SwiftUI

class DayCounterViewModel: ObservableObject {
    @Published var sobrietyData: SobrietyData

    private let storageKey = "sobriety_data"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(SobrietyData.self, from: data) {
            sobrietyData = decoded
        } else {
            // First time user
            sobrietyData = SobrietyData(currentStartDate: DateProvider.now, pastStreaks: [])
            save()
        }
        
        #if DEBUG
        NotificationCenter.default.addObserver(forName: .dateOffsetChanged, object: nil, queue: .main) { [weak self] _ in
            self?.refresh()
        }
        #endif
    }

    // Save to UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(sobrietyData) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    // Reset streak (archive current and start new)
    func resetStreak() {
        let today = DateProvider.now
        let length = Calendar.current.dateComponents([.day], from: sobrietyData.currentStartDate, to: today).day ?? 0

        let finishedStreak = Streak(
            id: UUID(),
            startDate: sobrietyData.currentStartDate,
            endDate: today,
            length: length
        )

        sobrietyData.pastStreaks.append(finishedStreak)
        sobrietyData.currentStartDate = today
        save()
    }
    
    func refresh() {
        objectWillChange.send()
    }

    // Calculate days since currentStartDate
    var currentStreak: Int {
        Calendar.current.dateComponents([.day], from: sobrietyData.currentStartDate, to: DateProvider.now).day ?? 0
    }

    var totalAttempts: Int {
        sobrietyData.pastStreaks.count + 1
    }

    var longestStreak: Int {
        let past = sobrietyData.pastStreaks.map { $0.length }.max() ?? 0
        return max(past, currentStreak)
    }
}
